extends StaticBody3D
class_name BlockBase

const FRAME_HP: int = 1

enum SnapMode {
	CENTER,
	EDGE,
}

signal hp_changed(current_hp: int, max_hp: int)
signal block_destroyed()

@export var max_hp: int = 100
@export var recipe: RecipeData = null
@export var build_size: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var snap_mode: SnapMode = SnapMode.CENTER
@export var occupied_cells: Array[Vector3i] = [Vector3i.ZERO]

var current_hp: int = FRAME_HP
var root_cell: Vector3i = Vector3i.ZERO
var placed_yaw_steps: int = 0
var occupied_world_cells: Array[Vector3i] = []

func _ready() -> void:
	current_hp = FRAME_HP
	_update_visual()

func is_frame() -> bool:
	return current_hp <= FRAME_HP

func get_repair_cost() -> Dictionary:
	var cost: Dictionary = {}
	if recipe == null or max_hp <= 0:
		return cost
	var missing_ratio: float = float(max_hp - current_hp) / float(max_hp)
	cost[ResourceType.Type.ORE] = ceili(recipe.cost_ore * missing_ratio)
	cost[ResourceType.Type.LIMESTONE] = ceili(recipe.cost_limestone * missing_ratio)
	cost[ResourceType.Type.CRYSTALS] = ceili(recipe.cost_crystals * missing_ratio)
	return cost

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	_update_visual()
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		block_destroyed.emit()
		queue_free()

func apply_repair() -> void:
	current_hp = max_hp
	_update_visual()
	hp_changed.emit(current_hp, max_hp)

func _update_visual() -> void:
	pass
