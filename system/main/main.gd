extends Node3D
class_name Main

@onready var menu_manager: MenuManager = %MenuManager
@onready var game_root: Node3D = %GameRoot

func _ready() -> void:
	menu_manager.show_menu(Menu.Type.MAIN)

func start_game() -> void:
	menu_manager.hide_current_menu()
	#TODO: Open GameRoot

func return_to_main_menu() -> void:
	get_tree().paused = false
	menu_manager.show_menu(Menu.Type.MAIN)

func show_pause_menu() -> void:
	menu_manager.show_menu(Menu.Type.PAUSE)

func resume_from_pause() -> void:
	get_tree().paused = false
	menu_manager.hide_current_menu()
