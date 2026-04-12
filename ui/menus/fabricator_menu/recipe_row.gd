extends HBoxContainer
class_name RecipeRow

signal craft_requested(recipe: RecipeData)

@onready var _name_label: Label = $InfoSection/NameLabel
@onready var _cost_label: Label = $InfoSection/CostLabel
@onready var _craft_button: Button = $CraftButton

var _recipe: RecipeData = null

func setup(recipe: RecipeData) -> void:
	_recipe = recipe
	_name_label.text = recipe.display_name
	var costs: Array[String] = []
	if recipe.cost_ore > 0:
		costs.append("%d ORE" % recipe.cost_ore)
	if recipe.cost_limestone > 0:
		costs.append("%d LMSTN" % recipe.cost_limestone)
	if recipe.cost_crystals > 0:
		costs.append("%d XTAL" % recipe.cost_crystals)
	_cost_label.text = "  ".join(costs) if costs.size() > 0 else "Free"
	_craft_button.pressed.connect(_on_craft_pressed)

func refresh(inv: PlayerInventory) -> void:
	if _recipe == null:
		return
	_craft_button.disabled = not _can_afford(inv)

func _can_afford(inv: PlayerInventory) -> bool:
	return (
		inv.get_count(ResourceType.Type.ORE) >= _recipe.cost_ore and
		inv.get_count(ResourceType.Type.LIMESTONE) >= _recipe.cost_limestone and
		inv.get_count(ResourceType.Type.CRYSTALS) >= _recipe.cost_crystals
	)

func _on_craft_pressed() -> void:
	craft_requested.emit(_recipe)
