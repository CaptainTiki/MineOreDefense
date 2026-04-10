extends Menu
class_name FabricatorMenu

@onready var _close_button: Button = $Panel/VBox/CloseButton

func _ready() -> void:
	super()
	_close_button.pressed.connect(_on_close_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_close_pressed()

func _on_close_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	MenuManager.instance.hide_current_menu()
