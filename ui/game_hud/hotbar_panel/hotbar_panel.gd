extends HBoxContainer
class_name HotbarPanel

const SLOT_COUNT: int = 6

@onready var _slot_uis: Array[HotbarSlotUI] = [
	$Slot1, $Slot2, $Slot3, $Slot4, $Slot5, $Slot6,
]

var _hotbar: Hotbar = null
var _build_inventory: BuildInventory = null

func _ready() -> void:
	for i: int in SLOT_COUNT:
		_slot_uis[i].setup(i + 1)

	GameData.instance.hotbar_ready.connect(_on_hotbar_ready)
	if GameData.instance.hotbar != null:
		_on_hotbar_ready(GameData.instance.hotbar)

func _on_hotbar_ready(hotbar: Hotbar) -> void:
	_hotbar = hotbar
	_hotbar.active_slot_changed.connect(_on_active_slot_changed)
	_hotbar.slot_updated.connect(_on_slot_updated)

	## Inject hotbar ref into each slot UI so they can handle drops
	for i: int in SLOT_COUNT:
		_slot_uis[i].set_hotbar_ref(_hotbar)

	## Subscribe to BuildInventory for live count updates on BLOCK slots
	if GameData.instance.build_inventory != null:
		_build_inventory = GameData.instance.build_inventory
		_build_inventory.build_inventory_changed.connect(_on_build_inventory_changed)

	_refresh_all()

func _refresh_all() -> void:
	for i: int in SLOT_COUNT:
		var slot: HotbarSlotData = _hotbar.get_slot(i)
		_slot_uis[i].update_slot(slot)
		if slot.slot_type == HotbarSlotData.SlotType.BLOCK and _build_inventory != null:
			_slot_uis[i].update_block_count(_build_inventory.get_count(slot.block_name))
	_update_active_highlight(_hotbar.get_active_index())

func _on_active_slot_changed(index: int, _slot: HotbarSlotData) -> void:
	_update_active_highlight(index)

func _on_slot_updated(index: int, slot: HotbarSlotData) -> void:
	_slot_uis[index].update_slot(slot)
	if slot.slot_type == HotbarSlotData.SlotType.BLOCK and _build_inventory != null:
		_slot_uis[index].update_block_count(_build_inventory.get_count(slot.block_name))

func _on_build_inventory_changed(item_name: String, new_count: int) -> void:
	## Update any hotbar slot that is showing this block type
	for i: int in SLOT_COUNT:
		var slot: HotbarSlotData = _hotbar.get_slot(i)
		if slot.slot_type == HotbarSlotData.SlotType.BLOCK and slot.block_name == item_name:
			_slot_uis[i].update_block_count(new_count)

func _update_active_highlight(active_index: int) -> void:
	for i: int in SLOT_COUNT:
		_slot_uis[i].set_active(i == active_index)
