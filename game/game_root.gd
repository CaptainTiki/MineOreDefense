extends Node3D
class_name GameRoot

static var instance: GameRoot

var _active_level: Level = null

@onready var _hud: GameHud = $GameHud

func _ready() -> void:
	GameRoot.instance = self
	_hud.hide()

func load_level(level: Level) -> void:
	if _active_level != null:
		unload_level()
	_active_level = level
	level.resource_count_changed.connect(_on_resource_count_changed)
	add_child(level)
	_hud.show()

func unload_level() -> void:
	if _active_level == null:
		return
	_hud.hide()
	_active_level.queue_free()
	_active_level = null

## Adds a block to the active level so it is cleaned up when the level unloads.
func place_block(block: Node3D) -> void:
	if _active_level != null:
		_active_level.add_child(block)

func _on_resource_count_changed(type: ResourceType.Type, count: int) -> void:
	_hud.update_resource(type, count)
