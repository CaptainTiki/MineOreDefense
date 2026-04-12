extends CanvasLayer
class_name GameHud

@onready var _resource_panel: ResourceCounterPanel = $HudContainer/ResourceCounterPanel
@onready var _wave_panel: WaveInfoPanel = $HudContainer/WaveInfoPanel
@onready var _hotbar_panel: HotbarPanel = $HudContainer/HotbarPanel
@onready var _inventory_panel: InventoryPanel = $HudContainer/InventoryPanel
@onready var _block_info_panel: BlockInfoPanel = $HudContainer/BlockInfoPanel
@onready var _core_pod_health_bar: CorePodHealthBar = $HudContainer/CorePodHealthBar
@onready var _announcement_label: Label = $HudContainer/AnnouncementLabel

var _announcement_timer: float = 0.0

func _ready() -> void:
	_announcement_label.hide()

func _process(delta: float) -> void:
	if _announcement_timer <= 0.0:
		return

	_announcement_timer = max(0.0, _announcement_timer - delta)
	if _announcement_timer == 0.0:
		_announcement_label.hide()

func update_resource(type: ResourceType.Type, count: int) -> void:
	_resource_panel.update_count(type, count)

func update_core_pod_health(pct: float) -> void:
	_core_pod_health_bar.set_health_percent(pct)

func update_wave_phase(phase_name: String) -> void:
	_wave_panel.set_phase(phase_name)

func update_wave_day(day: int) -> void:
	_wave_panel.set_day(day)

func show_announcement(text: String, duration: float = 2.5) -> void:
	_announcement_label.text = text
	_announcement_label.show()
	_announcement_timer = duration
