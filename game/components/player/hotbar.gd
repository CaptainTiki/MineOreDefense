extends Node
class_name Hotbar

signal active_slot_changed(slot_index: int, slot: HotbarSlotData)
signal slot_updated(slot_index: int, slot: HotbarSlotData)

const SLOT_COUNT: int = 6
const DEFAULT_SLOT_PATHS: Array[String] = [
	"res://resources/hotbar/slot_assault_rifle.tres",
	"res://resources/hotbar/slot_mining_laser.tres",
	"res://resources/hotbar/slot_build_tool.tres",
]

var _slots: Array[HotbarSlotData] = []
var _active_index: int = 0

func _ready() -> void:
	# Fill all slots with empty data first
	for i: int in SLOT_COUNT:
		_slots.append(HotbarSlotData.new())

	# Load default weapon slots
	for i: int in min(DEFAULT_SLOT_PATHS.size(), SLOT_COUNT):
		var slot: HotbarSlotData = load(DEFAULT_SLOT_PATHS[i]) as HotbarSlotData
		if slot != null:
			_slots[i] = slot

func _unhandled_input(event: InputEvent) -> void:
	## Only process hotbar input while the mouse is captured (gameplay mode)
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			var keycode: Key = key_event.keycode
			if keycode >= KEY_1 and keycode <= KEY_6:
				set_active(keycode - KEY_1)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed:
			if mouse_event.alt_pressed:
				return
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				set_active((_active_index - 1 + SLOT_COUNT) % SLOT_COUNT)
				get_viewport().set_input_as_handled()
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				set_active((_active_index + 1) % SLOT_COUNT)
				get_viewport().set_input_as_handled()

func set_active(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return
	_active_index = index
	active_slot_changed.emit(_active_index, _slots[_active_index])

func assign_slot(index: int, slot: HotbarSlotData) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return
	_slots[index] = slot
	slot_updated.emit(index, slot)
	if index == _active_index:
		active_slot_changed.emit(_active_index, slot)

func get_slot(index: int) -> HotbarSlotData:
	if index < 0 or index >= SLOT_COUNT:
		return HotbarSlotData.new()
	return _slots[index]

func get_active_slot() -> HotbarSlotData:
	return _slots[_active_index]

func get_active_index() -> int:
	return _active_index
