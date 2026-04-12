extends Node3D
class_name BuildGhost

@export var preview_root: Node3D = null

var _valid_mat: StandardMaterial3D = null
var _invalid_mat: StandardMaterial3D = null
var _mesh_instances: Array[MeshInstance3D] = []
var _current_scene_path: String = ""

func _ready() -> void:
	_valid_mat = StandardMaterial3D.new()
	_valid_mat.albedo_color = Color(0.0, 1.0, 0.9, 0.3)
	_valid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_valid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_valid_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	_invalid_mat = StandardMaterial3D.new()
	_invalid_mat.albedo_color = Color(1.0, 0.2, 0.2, 0.3)
	_invalid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_invalid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_invalid_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

func set_definition(definition: BuildDefinition) -> void:
	if preview_root == null:
		return

	var scene_path: String = ""
	if definition != null and definition.block_scene != null:
		scene_path = definition.block_scene.resource_path

	if scene_path == _current_scene_path:
		return

	_current_scene_path = scene_path
	_clear_preview()

	if definition == null or definition.block_scene == null:
		return

	var preview_source: Node = definition.block_scene.instantiate()
	_clone_visual_branch(preview_source, preview_root)
	preview_source.free()
	_apply_material(_valid_mat)

func set_valid(valid: bool) -> void:
	_apply_material(_valid_mat if valid else _invalid_mat)

func set_size(size: Vector3) -> void:
	pass

func _clear_preview() -> void:
	_mesh_instances.clear()
	for child: Node in preview_root.get_children():
		child.free()

func _clone_visual_branch(source: Node, target_parent: Node3D) -> void:
	for child: Node in source.get_children():
		if child is MeshInstance3D:
			var source_mesh: MeshInstance3D = child as MeshInstance3D
			var clone: MeshInstance3D = MeshInstance3D.new()
			clone.name = source_mesh.name
			clone.transform = source_mesh.transform
			clone.mesh = source_mesh.mesh
			clone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			target_parent.add_child(clone)
			_mesh_instances.append(clone)
			_clone_visual_branch(source_mesh, clone)
		elif child is Node3D:
			var pivot: Node3D = Node3D.new()
			pivot.name = child.name
			pivot.transform = (child as Node3D).transform
			target_parent.add_child(pivot)
			_clone_visual_branch(child, pivot)
		else:
			_clone_visual_branch(child, target_parent)

func _apply_material(material: Material) -> void:
	for mesh_instance: MeshInstance3D in _mesh_instances:
		var surface_count: int = mesh_instance.mesh.get_surface_count() if mesh_instance.mesh != null else 0
		for surface_index: int in range(surface_count):
			mesh_instance.set_surface_override_material(surface_index, material)
