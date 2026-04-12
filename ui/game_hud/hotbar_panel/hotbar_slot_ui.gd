extends PanelContainer
class_name HotbarSlotUI

@export var normal_style: StyleBoxFlat = null
@export var active_style: StyleBoxFlat = null

@onready var _number_label: Label = $VBox/NumberLabel
@onready var _name_label: Label = $VBox/NameLabel
@onready var _count_label: Label = $VBox/CountLabel

var _slot_index: int = 0
var _hotbar: Hotbar = null

func setup(slot_number: int) -> void:
	_slot_index = slot_number - 1
	_number_label.text = str(slot_number)

func set_hotbar_ref(hotbar: Hotbar) -> void:
	_hotbar = hotbar

func update_slot(slot: HotbarSlotData) -> void:
	match slot.slot_type:
		HotbarSlotData.SlotType.EMPTY:
			_name_label.text = "---"
			_count_label.visible = false
		HotbarSlotData.SlotType.WEAPON:
			_name_label.text = slot.display_name
			_count_label.visible = false
		HotbarSlotData.SlotType.BLOCK:
			_name_label.text = slot.display_name
			_count_label.visible = true
			_count_label.text = "x0"

func update_block_count(count: int) -> void:
	_count_label.text = "x%d" % count

func set_active(is_active: bool) -> void:
	if is_active and active_style != null:
		add_theme_stylebox_override("panel", active_style)
	elif normal_style != null:
		add_theme_stylebox_override("panel", normal_style)

## Drag/drop target — accept only block drag data from InventoryItemUI
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	return (data as Dictionary).has("display_name")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _hotbar == null:
		return
	var display_name: String = (data as Dictionary).get("display_name", "") as String
	if display_name.is_empty():
		return
	var slot: HotbarSlotData = HotbarSlotData.new()
	slot.slot_type = HotbarSlotData.SlotType.BLOCK
	slot.display_name = display_name
	slot.block_name = display_name
	_hotbar.assign_slot(_slot_index, slot)
