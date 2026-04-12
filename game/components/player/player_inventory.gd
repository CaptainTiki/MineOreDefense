extends Node
class_name PlayerInventory

signal inventory_changed(type: ResourceType.Type, new_count: int)

var _resources: Dictionary = {
	ResourceType.Type.ORE: 0,
	ResourceType.Type.LIMESTONE: 0,
	ResourceType.Type.CRYSTALS: 0,
}

func add_resource(type: ResourceType.Type, amount: int) -> void:
	var current: int = _resources[type] as int
	_resources[type] = current + amount
	var new_count: int = _resources[type] as int
	inventory_changed.emit(type, new_count)
	print("Inventory [%s]: %d" % [ResourceType.Type.keys()[type], new_count])

func get_count(type: ResourceType.Type) -> int:
	return _resources[type] as int

func remove_resource(type: ResourceType.Type, amount: int) -> void:
	var current: int = _resources[type] as int
	_resources[type] = max(0, current - amount)
	var new_count: int = _resources[type] as int
	inventory_changed.emit(type, new_count)
