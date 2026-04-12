extends Node
class_name BuildInventory

signal build_inventory_changed(item_name: String, new_count: int)

## Keyed by recipe display_name → count of crafted items
var _items: Dictionary = {}

func add_item(item_name: String, amount: int = 1) -> void:
	var current: int = _items.get(item_name, 0) as int
	_items[item_name] = current + amount
	build_inventory_changed.emit(item_name, _items[item_name] as int)

func get_count(item_name: String) -> int:
	return _items.get(item_name, 0) as int

func remove_item(item_name: String, amount: int = 1) -> void:
	var current: int = _items.get(item_name, 0) as int
	var new_count: int = max(0, current - amount)
	if new_count == 0:
		_items.erase(item_name)
	else:
		_items[item_name] = new_count
	build_inventory_changed.emit(item_name, new_count)

func get_all() -> Dictionary:
	return _items.duplicate()
