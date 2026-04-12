extends Node3D
class_name GameRoot

## Emitted when the CorePod is destroyed — Main connects to trigger game over.
signal game_over_triggered()

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
	level.core_pod_health_changed.connect(_on_core_pod_health_changed)
	level.core_pod_destroyed.connect(_on_core_pod_destroyed)
	level.phase_changed.connect(_on_phase_changed)
	level.day_changed.connect(_on_day_changed)
	level.announcement_requested.connect(_on_announcement_requested)
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

func get_active_level() -> Level:
	return _active_level

func _on_resource_count_changed(type: ResourceType.Type, count: int) -> void:
	_hud.update_resource(type, count)

func _on_core_pod_health_changed(pct: float) -> void:
	_hud.update_core_pod_health(pct)

func _on_core_pod_destroyed() -> void:
	game_over_triggered.emit()

func _on_phase_changed(phase: int) -> void:
	_hud.update_wave_phase(DayNightCycle.phase_label(phase as DayNightCycle.Phase))

func _on_day_changed(day: int) -> void:
	_hud.update_wave_day(day)

func _on_announcement_requested(text: String, duration: float) -> void:
	_hud.show_announcement(text, duration)
