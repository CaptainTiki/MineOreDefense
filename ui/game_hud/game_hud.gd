extends CanvasLayer
class_name GameHud

@onready var _resource_panel: ResourceCounterPanel = $HudContainer/ResourceCounterPanel
@onready var _wave_panel: WaveInfoPanel = $HudContainer/WaveInfoPanel
@onready var _hotbar_panel: HotbarPanel = $HudContainer/HotbarPanel
@onready var _inventory_panel: InventoryPanel = $HudContainer/InventoryPanel
@onready var _block_info_panel: BlockInfoPanel = $HudContainer/BlockInfoPanel

func update_resource(type: ResourceType.Type, count: int) -> void:
	_resource_panel.update_count(type, count)
