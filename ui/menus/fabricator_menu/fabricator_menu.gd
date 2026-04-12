extends Menu
class_name FabricatorMenu

const RECIPE_PATHS: Array[String] = [
	"res://resources/recipes/wall_segment.tres",
	"res://resources/recipes/floor_tile.tres",
	"res://resources/recipes/basic_turret.tres",
	"res://resources/recipes/generator.tres",
]
const ROW_SCENE: String = "res://ui/menus/fabricator_menu/recipe_row.tscn"

@onready var _ore_label: Label = $Panel/VBox/InventoryRow/OreLabel
@onready var _limestone_label: Label = $Panel/VBox/InventoryRow/LimestoneLabel
@onready var _crystals_label: Label = $Panel/VBox/InventoryRow/CrystalsLabel
@onready var _recipe_list: VBoxContainer = $Panel/VBox/RecipeScroll/RecipeList
@onready var _close_button: Button = $Panel/VBox/CloseButton

var _rows: Array[RecipeRow] = []

func _ready() -> void:
	super()
	_close_button.pressed.connect(_on_close_pressed)
	_build_recipe_list()

func _build_recipe_list() -> void:
	var row_scene: PackedScene = load(ROW_SCENE) as PackedScene
	for path in RECIPE_PATHS:
		var recipe: RecipeData = load(path) as RecipeData
		if recipe == null:
			push_error("FabricatorMenu: failed to load recipe at %s" % path)
			continue
		var row: RecipeRow = row_scene.instantiate() as RecipeRow
		_recipe_list.add_child(row)
		row.setup(recipe)
		row.craft_requested.connect(_on_craft_requested)
		_rows.append(row)

func show_menu() -> void:
	super()
	_refresh()

func _refresh() -> void:
	var inv: PlayerInventory = GameData.instance.player_inventory
	if inv == null:
		return
	_ore_label.text = "ORE  %d" % inv.get_count(ResourceType.Type.ORE)
	_limestone_label.text = "LMSTN  %d" % inv.get_count(ResourceType.Type.LIMESTONE)
	_crystals_label.text = "XTAL  %d" % inv.get_count(ResourceType.Type.CRYSTALS)
	for row in _rows:
		row.refresh(inv)

func _on_craft_requested(recipe: RecipeData) -> void:
	var inv: PlayerInventory = GameData.instance.player_inventory
	var build_inv: BuildInventory = GameData.instance.build_inventory
	if inv == null or build_inv == null:
		return
	if recipe.cost_ore > 0:
		inv.remove_resource(ResourceType.Type.ORE, recipe.cost_ore)
	if recipe.cost_limestone > 0:
		inv.remove_resource(ResourceType.Type.LIMESTONE, recipe.cost_limestone)
	if recipe.cost_crystals > 0:
		inv.remove_resource(ResourceType.Type.CRYSTALS, recipe.cost_crystals)
	build_inv.add_item(recipe.display_name)
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_close_pressed()

func _on_close_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	MenuManager.instance.hide_current_menu()
