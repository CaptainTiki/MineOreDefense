@tool
extends StaticBody3D
class_name DebugTerrain

## Procedurally generated rolling terrain for the debug level.
## @tool makes this run in the editor so the terrain is visible while placing objects.

const GRID_SIZE: int = 100
const GRID_STEPS: int = 64
const HEIGHT_SCALE: float = 3.0

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = 42
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.02
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

	var cell_size: float = float(GRID_SIZE) / float(GRID_STEPS - 1)
	var half: float = float(GRID_SIZE) / 2.0

	_mesh_instance.mesh = _build_mesh(noise, cell_size, half)
	_mesh_instance.material_override = _build_material()

	var hmap: HeightMapShape3D = _build_heightmap(noise, cell_size, half)
	_collision_shape.shape = hmap
	# Scale X/Z so each 1-unit heightmap cell maps to cell_size world units.
	# Y is left at 1.0 so height values are not stretched.
	_collision_shape.scale = Vector3(cell_size, 1.0, cell_size)


func _get_height(noise: FastNoiseLite, wx: float, wz: float) -> float:
	return noise.get_noise_2d(wx, wz) * HEIGHT_SCALE


func _build_mesh(noise: FastNoiseLite, cell_size: float, half: float) -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var eps: float = cell_size * 0.5

	for z: int in range(GRID_STEPS):
		for x: int in range(GRID_STEPS):
			var wx: float = x * cell_size - half
			var wz: float = z * cell_size - half
			var wy: float = _get_height(noise, wx, wz)

			# Gradient-based normal: tangent_z × tangent_x always gives +Y on upward surface.
			# tangent_x = (1, dh/dx, 0),  tangent_z = (0, dh/dz, 1)
			# normal    = tangent_z × tangent_x = (-dh/dx, 1, -dh/dz) normalised
			var dh_dx: float = (_get_height(noise, wx + eps, wz) - _get_height(noise, wx - eps, wz)) / (2.0 * eps)
			var dh_dz: float = (_get_height(noise, wx, wz + eps) - _get_height(noise, wx, wz - eps)) / (2.0 * eps)
			var normal: Vector3 = Vector3(-dh_dx, 1.0, -dh_dz).normalized()

			st.set_normal(normal)
			st.set_uv(Vector2(float(x) / float(GRID_STEPS - 1), float(z) / float(GRID_STEPS - 1)))
			st.add_vertex(Vector3(wx, wy, wz))

	for z: int in range(GRID_STEPS - 1):
		for x: int in range(GRID_STEPS - 1):
			var i: int = z * GRID_STEPS + x
			# CCW winding when viewed from above (+Y) — front face faces up
			st.add_index(i)
			st.add_index(i + 1)
			st.add_index(i + GRID_STEPS)
			st.add_index(i + 1)
			st.add_index(i + GRID_STEPS + 1)
			st.add_index(i + GRID_STEPS)

	return st.commit()


func _build_heightmap(noise: FastNoiseLite, cell_size: float, half: float) -> HeightMapShape3D:
	var shape: HeightMapShape3D = HeightMapShape3D.new()
	shape.map_width = GRID_STEPS
	shape.map_depth = GRID_STEPS

	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(GRID_STEPS * GRID_STEPS)

	for z: int in range(GRID_STEPS):
		for x: int in range(GRID_STEPS):
			var wx: float = x * cell_size - half
			var wz: float = z * cell_size - half
			data[z * GRID_STEPS + x] = _get_height(noise, wx, wz)

	shape.map_data = data
	return shape


func _build_material() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.24, 0.2, 1.0)
	mat.roughness = 0.9
	mat.metallic = 0.0
	return mat
