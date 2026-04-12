extends BlockBase
class_name CompositeBlock

@export var mesh_nodes: Array[NodePath] = []
@export var frame_material: Material = null
@export var full_material: Material = null

func _update_visual() -> void:
	var material: Material = frame_material if is_frame() else full_material
	for path: NodePath in mesh_nodes:
		var mesh_instance: MeshInstance3D = get_node_or_null(path) as MeshInstance3D
		if mesh_instance != null:
			mesh_instance.set_surface_override_material(0, material)
