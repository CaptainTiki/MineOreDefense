extends Resource
class_name HotbarSlotData

enum SlotType {
	EMPTY,   ## Slot holds nothing
	WEAPON,  ## Slot holds a weapon / tool (has weapon_scene)
	BLOCK,   ## Slot holds a buildable block type — assigned in Phase 3
}

@export var slot_type: SlotType = SlotType.EMPTY
@export var display_name: String = ""
@export var weapon_scene: PackedScene = null
## Block slots store the recipe display_name to look up count in BuildInventory
@export var block_name: String = ""
