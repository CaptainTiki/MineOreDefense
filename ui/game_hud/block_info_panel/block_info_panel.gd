extends PanelContainer
class_name BlockInfoPanel

@onready var _block_name_label: Label  = $Margin/VBox/BlockNameLabel
@onready var _hp_label: Label          = $Margin/VBox/HPLabel
@onready var _hp_bar: ProgressBar      = $Margin/VBox/HPBar
@onready var _cost_container: VBoxContainer = $Margin/VBox/CostContainer
@onready var _ore_label: Label         = $Margin/VBox/CostContainer/OreLabel
@onready var _limestone_label: Label   = $Margin/VBox/CostContainer/LimestoneLabel
@onready var _crystals_label: Label    = $Margin/VBox/CostContainer/CrystalsLabel
@onready var _full_label: Label        = $Margin/VBox/FullLabel

var _current_block: BlockBase = null

func _ready() -> void:
	hide()
	GameData.instance.target_block_changed.connect(_on_target_block_changed)

func _on_target_block_changed(block: BlockBase) -> void:
	## Disconnect hp_changed from the previous block
	if _current_block != null and is_instance_valid(_current_block):
		if _current_block.hp_changed.is_connected(_on_hp_changed):
			_current_block.hp_changed.disconnect(_on_hp_changed)

	_current_block = block

	if block == null:
		hide()
		return

	block.hp_changed.connect(_on_hp_changed)
	_refresh(block)
	show()

func _on_hp_changed(_current: int, _max: int) -> void:
	if _current_block == null or not is_visible():
		return
	_refresh(_current_block)

func _refresh(block: BlockBase) -> void:
	## Name
	if block.recipe != null:
		_block_name_label.text = block.recipe.display_name
	else:
		_block_name_label.text = block.name

	## HP bar
	_hp_bar.max_value = block.max_hp
	_hp_bar.value = block.current_hp
	_hp_label.text = "%d / %d HP" % [block.current_hp, block.max_hp]

	## Repair cost
	var is_full: bool = block.current_hp >= block.max_hp
	_full_label.visible = is_full
	_cost_container.visible = not is_full

	if not is_full:
		var cost: Dictionary = block.get_repair_cost()
		var ore: int       = cost.get(ResourceType.Type.ORE,       0) as int
		var lime: int      = cost.get(ResourceType.Type.LIMESTONE,  0) as int
		var crystals: int  = cost.get(ResourceType.Type.CRYSTALS,   0) as int
		_ore_label.text       = "Ore: %d" % ore
		_limestone_label.text = "Limestone: %d" % lime
		_crystals_label.text  = "Crystals: %d" % crystals
