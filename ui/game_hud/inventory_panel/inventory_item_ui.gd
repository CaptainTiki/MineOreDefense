extends PanelContainer
class_name InventoryItemUI

@onready var _name_label: Label = $HBox/NameLabel
@onready var _count_label: Label = $HBox/CountLabel

var _item_name: String = ""

func setup(item_name: String, count: int) -> void:
	_item_name = item_name
	_name_label.text = item_name
	_count_label.text = "x%d" % count

func update_count(count: int) -> void:
	_count_label.text = "x%d" % count

## Called by Godot when a drag starts from this control
func _get_drag_data(_at_position: Vector2) -> Variant:
	if _item_name.is_empty():
		return null
	## Build a simple preview label
	var preview: Label = Label.new()
	preview.text = _item_name
	preview.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0, 1.0))
	set_drag_preview(preview)
	return {"display_name": _item_name}
