extends Node3D
class_name Main

@onready var menu_manager: MenuManager = %MenuManager
@onready var game_root: GameRoot = %GameRoot

var _in_game: bool = false

func _ready() -> void:
	menu_manager.show_menu(Menu.Type.MAIN)

func _unhandled_input(event: InputEvent) -> void:
	if _in_game and event.is_action_pressed("ui_cancel"):
		show_pause_menu()

func start_game() -> void:
	_in_game = true
	menu_manager.hide_current_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not game_root.game_over_triggered.is_connected(show_game_over):
		game_root.game_over_triggered.connect(show_game_over)
	var level: Level = LevelPrefabs.debug_level_scene.instantiate()
	game_root.load_level(level)

func return_to_main_menu() -> void:
	_in_game = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_root.unload_level()
	menu_manager.show_menu(Menu.Type.MAIN)

func show_pause_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_manager.show_menu(Menu.Type.PAUSE)

func resume_from_pause() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu_manager.hide_current_menu()

func show_game_over() -> void:
	_in_game = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_root.unload_level()
	menu_manager.show_menu(Menu.Type.MAIN)
