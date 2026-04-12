extends Node
class_name GameData

signal hotbar_ready(hotbar: Hotbar)
signal target_block_changed(block: BlockBase)

static var instance: GameData

var run: RunData = RunData.new()

## Set by the level after spawning the player — used by menus that need inventory access
var player_inventory: PlayerInventory = null
var build_inventory: BuildInventory = null
var hotbar: Hotbar = null
var current_target_block: BlockBase = null

func _ready() -> void:
	instance = self

func reset_for_new_game() -> void:
	run = RunData.new()

func set_hotbar(h: Hotbar) -> void:
	hotbar = h
	hotbar_ready.emit(hotbar)

func set_target_block(block: BlockBase) -> void:
	if block == current_target_block:
		return
	current_target_block = block
	target_block_changed.emit(block)
