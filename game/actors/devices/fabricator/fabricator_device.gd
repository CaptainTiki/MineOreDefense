extends StaticBody3D
class_name FabricatorDevice

func interact() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	MenuManager.instance.show_menu(Menu.Type.FABRICATOR)
