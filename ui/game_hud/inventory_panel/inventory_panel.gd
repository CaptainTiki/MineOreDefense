extends Control
class_name InventoryPanel

const ITEM_SCENE: String = "res://ui/game_hud/inventory_panel/inventory_item_ui.tscn"

@onready var _item_list: VBoxContainer = $Anchor/Panel/VBox/ScrollContainer/ItemList
@onready var _empty_label: Label = $Anchor/Panel/VBox/EmptyLabel

## Keyed by item_name → InventoryItemUI
var _item_uis: Dictionary = {}
var _build_inventory: BuildInventory = null

func _ready() -> void:
	hide()
	## Connect once build inventory is available via GameData
	GameData.instance.hotbar_ready.connect(_on_game_ready)
	if GameData.instance.build_inventory != null:
		_connect_build_inventory(GameData.instance.build_inventory)

func _on_game_ready(_hotbar: Hotbar) -> void:
	if GameData.instance.build_inventory != null:
		_connect_build_inventory(GameData.instance.build_inventory)

func _connect_build_inventory(inv: BuildInventory) -> void:
	_build_inventory = inv
	_build_inventory.build_inventory_changed.connect(_on_build_inventory_changed)

func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null:
		return
	if not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode != KEY_TAB:
		return
	## Don't open over other menus
	if MenuManager.instance.current_menu != null:
		return
	get_viewport().set_input_as_handled()
	if visible:
		_close()
	else:
		_open()

func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_refresh()
	show()

func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func _refresh() -> void:
	if _build_inventory == null:
		return
	var all_items: Dictionary = _build_inventory.get_all()
	_empty_label.visible = all_items.is_empty()

	## Add rows for any new items, update counts for existing ones
	for item_name: String in all_items:
		var count: int = all_items[item_name] as int
		if _item_uis.has(item_name):
			(_item_uis[item_name] as InventoryItemUI).update_count(count)
		else:
			var scene: PackedScene = load(ITEM_SCENE) as PackedScene
			var item_ui: InventoryItemUI = scene.instantiate() as InventoryItemUI
			_item_list.add_child(item_ui)
			item_ui.setup(item_name, count)
			_item_uis[item_name] = item_ui

func _on_build_inventory_changed(item_name: String, new_count: int) -> void:
	if _item_uis.has(item_name):
		(_item_uis[item_name] as InventoryItemUI).update_count(new_count)
	elif visible:
		## New item type appeared while panel is open — refresh
		_refresh()
