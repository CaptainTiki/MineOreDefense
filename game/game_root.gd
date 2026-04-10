extends Node3D
class_name GameRoot

static var instance: GameRoot

var _active_level: Level = null

func _ready() -> void:
	GameRoot.instance = self

func load_level(level: Level) -> void:
	if _active_level != null:
		unload_level()
	_active_level = level
	add_child(level)

func unload_level() -> void:
	if _active_level == null:
		return
	_active_level.queue_free()
	_active_level = null
