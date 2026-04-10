extends PanelContainer
class_name ResourceCounterPanel

@onready var _ore_label: Label = $VBox/OreRow/OreCount
@onready var _limestone_label: Label = $VBox/LimestoneRow/LimestoneCount
@onready var _crystals_label: Label = $VBox/CrystalsRow/CrystalsCount

func update_count(type: ResourceType.Type, count: int) -> void:
	match type:
		ResourceType.Type.ORE:
			_ore_label.text = "Ore: %d" % count
		ResourceType.Type.LIMESTONE:
			_limestone_label.text = "Limestone: %d" % count
		ResourceType.Type.CRYSTALS:
			_crystals_label.text = "Crystals: %d" % count
