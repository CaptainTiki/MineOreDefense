extends BlockBase
class_name VisualBlock

@export var mesh_instance: MeshInstance3D = null
@export var frame_material: Material = null
@export var full_material: Material = null

func _update_visual() -> void:
	if mesh_instance == null:
		return
	if is_frame():
		mesh_instance.set_surface_override_material(0, frame_material)
	else:
		mesh_instance.set_surface_override_material(0, full_material)
