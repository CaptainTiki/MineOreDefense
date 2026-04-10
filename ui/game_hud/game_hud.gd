extends CanvasLayer
class_name GameHud

@onready var _resource_panel: ResourceCounterPanel = $HudContainer/ResourceCounterPanel
@onready var _wave_panel: WaveInfoPanel = $HudContainer/WaveInfoPanel

func update_resource(type: ResourceType.Type, count: int) -> void:
	_resource_panel.update_count(type, count)
