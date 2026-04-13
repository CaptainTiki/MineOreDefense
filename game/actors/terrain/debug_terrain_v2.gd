@tool
extends StaticBody3D
class_name DebugTerrainHeightmap

signal terrain_rebuilt

## Heightmap-driven terrain for authored level building.
## Assign a grayscale texture in the inspector and this script will rebuild
## the terrain mesh/collision in editor so prop placement matches runtime.

@export var heightmap_texture: Texture2D = null:
	set(value):
		heightmap_texture = value
		_queue_rebuild()

@export var terrain_size: Vector2 = Vector2(180.0, 180.0):
	set(value):
		terrain_size = Vector2(maxf(value.x, 8.0), maxf(value.y, 8.0))
		_queue_rebuild()

@export var height_scale: float = 22.0:
	set(value):
		height_scale = maxf(value, 0.0)
		_queue_rebuild()

@export var base_height: float = 0.0:
	set(value):
		base_height = value
		_queue_rebuild()

@export var invert_heightmap: bool = false:
	set(value):
		invert_heightmap = value
		_queue_rebuild()

@export var edge_rim_height: float = 6.0:
	set(value):
		edge_rim_height = maxf(value, 0.0)
		_queue_rebuild()

@export var edge_rim_width: float = 18.0:
	set(value):
		edge_rim_width = maxf(value, 0.01)
		_queue_rebuild()

@export var auto_rebuild_in_editor: bool = true

var _mesh_instance: MeshInstance3D = null
var _collision_shape: CollisionShape3D = null

var _height_image: Image = null
var _height_width: int = 0
var _height_depth: int = 0
var _height_data: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	_ensure_runtime_nodes()
	_rebuild_terrain()

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY and Engine.is_editor_hint():
		_ensure_runtime_nodes()
		_rebuild_terrain()

func sample_height(world_x: float, world_z: float) -> float:
	if _height_width <= 1 or _height_depth <= 1:
		_cache_height_source()
	if _height_width <= 1 or _height_depth <= 1:
		return base_height

	var half_size: Vector2 = terrain_size * 0.5
	var uv_x: float = clampf((world_x + half_size.x) / terrain_size.x, 0.0, 1.0)
	var uv_z: float = clampf((world_z + half_size.y) / terrain_size.y, 0.0, 1.0)
	var source_height: float = _sample_height_uv(uv_x, uv_z)
	return base_height + (source_height * height_scale) + _edge_rim(world_x, world_z)

func _queue_rebuild() -> void:
	if not is_inside_tree():
		return
	if Engine.is_editor_hint() and not auto_rebuild_in_editor:
		return
	call_deferred("_rebuild_terrain")

func _rebuild_terrain() -> void:
	_ensure_runtime_nodes()
	_cache_height_source()
	if _height_width <= 1 or _height_depth <= 1:
		return

	var mesh: ArrayMesh = _build_mesh()
	_mesh_instance.mesh = mesh
	_mesh_instance.material_override = _build_material()

	var hmap: HeightMapShape3D = _build_heightmap()
	_collision_shape.shape = hmap
	_collision_shape.scale = Vector3(
		terrain_size.x / float(_height_width - 1),
		1.0,
		terrain_size.y / float(_height_depth - 1)
	)
	terrain_rebuilt.emit()

func _ensure_runtime_nodes() -> void:
	if _mesh_instance == null or not is_instance_valid(_mesh_instance):
		_mesh_instance = get_node_or_null("GeneratedMesh") as MeshInstance3D
	if _mesh_instance == null:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "GeneratedMesh"
		add_child(_mesh_instance)
		_mesh_instance.owner = null

	if _collision_shape == null or not is_instance_valid(_collision_shape):
		_collision_shape = get_node_or_null("GeneratedCollision") as CollisionShape3D
	if _collision_shape == null:
		_collision_shape = CollisionShape3D.new()
		_collision_shape.name = "GeneratedCollision"
		add_child(_collision_shape)
		_collision_shape.owner = null

func _cache_height_source() -> void:
	var image: Image = null
	if heightmap_texture != null:
		image = heightmap_texture.get_image()

	if image == null:
		image = _build_fallback_heightmap(128, 128)

	image.convert(Image.FORMAT_RF)
	_height_image = image
	_height_width = image.get_width()
	_height_depth = image.get_height()
	_height_data = PackedFloat32Array()
	_height_data.resize(_height_width * _height_depth)

	for z: int in range(_height_depth):
		for x: int in range(_height_width):
			var height_value: float = image.get_pixel(x, z).r
			if invert_heightmap:
				height_value = 1.0 - height_value
			_height_data[(z * _height_width) + x] = height_value

func _sample_height_uv(uv_x: float, uv_z: float) -> float:
	var fx: float = uv_x * float(_height_width - 1)
	var fz: float = uv_z * float(_height_depth - 1)
	var x0: int = int(floor(fx))
	var z0: int = int(floor(fz))
	var x1: int = mini(x0 + 1, _height_width - 1)
	var z1: int = mini(z0 + 1, _height_depth - 1)
	var tx: float = fx - float(x0)
	var tz: float = fz - float(z0)

	var h00: float = _height_data[(z0 * _height_width) + x0]
	var h10: float = _height_data[(z0 * _height_width) + x1]
	var h01: float = _height_data[(z1 * _height_width) + x0]
	var h11: float = _height_data[(z1 * _height_width) + x1]

	var h0: float = lerpf(h00, h10, tx)
	var h1: float = lerpf(h01, h11, tx)
	return lerpf(h0, h1, tz)

func _build_mesh() -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half_size: Vector2 = terrain_size * 0.5
	var cell_x: float = terrain_size.x / float(_height_width - 1)
	var cell_z: float = terrain_size.y / float(_height_depth - 1)

	for z: int in range(_height_depth):
		for x: int in range(_height_width):
			var uv_x: float = float(x) / float(_height_width - 1)
			var uv_z: float = float(z) / float(_height_depth - 1)
			var wx: float = (uv_x * terrain_size.x) - half_size.x
			var wz: float = (uv_z * terrain_size.y) - half_size.y
			var wy: float = sample_height(wx, wz)

			var h_left: float = sample_height(wx - cell_x, wz)
			var h_right: float = sample_height(wx + cell_x, wz)
			var h_back: float = sample_height(wx, wz - cell_z)
			var h_forward: float = sample_height(wx, wz + cell_z)
			var dh_dx: float = (h_right - h_left) / maxf(cell_x * 2.0, 0.001)
			var dh_dz: float = (h_forward - h_back) / maxf(cell_z * 2.0, 0.001)
			var normal: Vector3 = Vector3(-dh_dx, 1.0, -dh_dz).normalized()

			st.set_normal(normal)
			st.set_uv(Vector2(uv_x, uv_z))
			st.add_vertex(Vector3(wx, wy, wz))

	for z: int in range(_height_depth - 1):
		for x: int in range(_height_width - 1):
			var i: int = (z * _height_width) + x
			st.add_index(i)
			st.add_index(i + 1)
			st.add_index(i + _height_width)
			st.add_index(i + 1)
			st.add_index(i + _height_width + 1)
			st.add_index(i + _height_width)

	return st.commit()

func _build_heightmap() -> HeightMapShape3D:
	var shape: HeightMapShape3D = HeightMapShape3D.new()
	shape.map_width = _height_width
	shape.map_depth = _height_depth

	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(_height_width * _height_depth)

	var half_size: Vector2 = terrain_size * 0.5
	for z: int in range(_height_depth):
		for x: int in range(_height_width):
			var uv_x: float = float(x) / float(_height_width - 1)
			var uv_z: float = float(z) / float(_height_depth - 1)
			var wx: float = (uv_x * terrain_size.x) - half_size.x
			var wz: float = (uv_z * terrain_size.y) - half_size.y
			data[(z * _height_width) + x] = sample_height(wx, wz)

	shape.map_data = data
	return shape

func _edge_rim(world_x: float, world_z: float) -> float:
	if edge_rim_height <= 0.0:
		return 0.0

	var half_size: Vector2 = terrain_size * 0.5
	var distance_to_edge: float = min(
		half_size.x - absf(world_x),
		half_size.y - absf(world_z)
	)
	var rim_t: float = clampf(1.0 - (distance_to_edge / edge_rim_width), 0.0, 1.0)
	return _smooth_step(rim_t) * edge_rim_height

func _build_fallback_heightmap(width: int, depth: int) -> Image:
	var image: Image = Image.create(width, depth, false, Image.FORMAT_RF)
	var center: Vector2 = Vector2(width - 1, depth - 1) * 0.5
	var max_radius: float = minf(center.x, center.y)

	for z: int in range(depth):
		for x: int in range(width):
			var p: Vector2 = Vector2(float(x), float(z))
			var radial: float = p.distance_to(center) / maxf(max_radius, 1.0)
			var starter_flat: float = _gaussian_2d(p, Vector2(center.x, center.y + 14.0), 0.34, 18.0)
			var west_site: float = _gaussian_2d(p, Vector2(center.x - 22.0, center.y + 6.0), 0.26, 14.0)
			var east_site: float = _gaussian_2d(p, Vector2(center.x + 24.0, center.y + 6.0), 0.24, 13.0)
			var north_basin: float = _gaussian_2d(p, Vector2(center.x, center.y - 24.0), -0.18, 16.0)
			var base_value: float = 0.42 - (radial * 0.06)
			var value: float = clampf(base_value + starter_flat + west_site + east_site + north_basin, 0.0, 1.0)
			image.set_pixel(x, z, Color(value, 0.0, 0.0, 1.0))

	return image

func _gaussian_2d(point: Vector2, center: Vector2, amplitude: float, radius: float) -> float:
	var distance_sq: float = point.distance_squared_to(center)
	var sigma_sq: float = radius * radius
	return amplitude * exp(-distance_sq / (2.0 * sigma_sq))

func _smooth_step(value: float) -> float:
	return value * value * (3.0 - (2.0 * value))

func _build_material() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.24, 0.2, 1.0)
	mat.roughness = 0.9
	mat.metallic = 0.0
	return mat
