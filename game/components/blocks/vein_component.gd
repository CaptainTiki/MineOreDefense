extends Node
class_name VeinComponent

signal resource_yielded(type: ResourceType.Type, amount: int)
signal vein_depleted()

@export var data: VeinData

var current_health: float = 0.0
var remaining_yield: int = 0

## Accumulated damage since the last yield event
var _damage_accumulator: float = 0.0

func _ready() -> void:
	if data == null:
		push_error("VeinComponent on %s has no VeinData assigned." % get_parent().name)
		return
	current_health = data.max_health
	remaining_yield = data.max_yield

## Called by the mining laser each physics frame it hits this vein.
func take_damage(amount: float) -> void:
	if remaining_yield <= 0:
		return

	current_health -= amount
	_damage_accumulator += amount

	# Yield a chunk of resource for every damage_per_yield absorbed
	while _damage_accumulator >= data.damage_per_yield and remaining_yield > 0:
		_damage_accumulator -= data.damage_per_yield
		remaining_yield -= 1
		resource_yielded.emit(data.vein_type, data.yield_per_threshold)

	if remaining_yield <= 0 or current_health <= 0.0:
		vein_depleted.emit()
		get_parent().queue_free()
