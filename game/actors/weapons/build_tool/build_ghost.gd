extends Node3D
class_name BuildGhost

@export var mesh_instance: MeshInstance3D = null

var _valid_mat: StandardMaterial3D = null
var _invalid_mat: StandardMaterial3D = null

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

	if mesh_instance != null:
		mesh_instance.set_surface_override_material(0, _valid_mat)

func set_valid(valid: bool) -> void:
	if mesh_instance == null:
		return
	mesh_instance.set_surface_override_material(0, _valid_mat if valid else _invalid_mat)
