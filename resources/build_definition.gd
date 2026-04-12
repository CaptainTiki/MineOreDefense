extends Resource
class_name BuildDefinition

@export var display_name: String = ""
@export var recipe: RecipeData = null
@export var block_scene: PackedScene = null
@export var footprint_cells: Array[Vector3i] = [Vector3i.ZERO]
@export var pivot_cell: Vector3i = Vector3i.ZERO
@export var yaw_rotations_supported: bool = true
@export var full_rotation_supported: bool = true
@export var preview_size: Vector3 = Vector3.ONE
@export var preview_offset: Vector3 = Vector3.ZERO
