extends CharacterBody3D
class_name PlayerController

signal resource_count_changed(type: ResourceType.Type, count: int)

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var debug : bool = false
@export_category("References")
@export var camera : CameraController
@export var state_chart : StateChart
@export var standing_collision : CollisionShape3D
@export var crouch_collision : CollisionShape3D
@export var stats: PlayerStats
@export var inventory: PlayerInventory
@export var build_inventory: BuildInventory
@export var weapon_mount: WeaponMount
@export var hotbar: Hotbar
@export var _interaction_ray: RayCast3D
@export var crouch_check: ShapeCast3D
@export var camera_effects: CameraEffects
@export_category("Easing")
@export var acceleration : float = 0.2
@export var deceleration : float = 0.5
@export_category("Speed")
@export var default_speed : float = 7.0
@export var sprint_speed_mod : float = 3
@export var crouch_speed_mod : float = -4
@export_category("Jump Settings")
@export var jump_velocity : float = 5
@export var fall_velocity_threshold : float = -5.0
@export_category("Data Helpers")
@export var data_relative_velocity : Vector3

@onready var state_chart_debugger: MarginContainer = $StateChartDebugger

var _input_dir : Vector2 = Vector2.ZERO
var _movement_velocity : Vector3 = Vector3.ZERO
var _sprint_modifier : float = 0.0
var _crouch_modifier : float = 0.0

var current_fall_velocity : float
var previous_velocity : Vector3
var ui_lock : bool = false


func _ready() -> void:
	stats.player_died.connect(_on_player_died)
	weapon_mount.resource_gathered.connect(_on_resource_gathered)
	inventory.inventory_changed.connect(_on_inventory_changed)
	hotbar.active_slot_changed.connect(_on_active_slot_changed)
	hotbar.set_active(hotbar.get_active_index())

func _physics_process(delta: float) -> void:
	# Apply gravity regardless of menu state
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# All gameplay input is blocked when the cursor is visible (menus / inventory open)
	var gameplay_input_active: bool = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

	if gameplay_input_active:
		# Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = stats.jump_velocity

		# Weapon fire
		if Input.is_action_just_pressed("fire"):
			weapon_mount.fire()
		if Input.is_action_just_released("fire"):
			weapon_mount.fire_released()
		if Input.is_action_just_pressed("secondary_fire"):
			weapon_mount.alt_fire()
		if Input.is_action_just_released("secondary_fire"):
			weapon_mount.alt_fire_released()

		# Interact
		if Input.is_action_just_pressed("interact") and _interaction_ray.is_colliding():
			var collider: Object = _interaction_ray.get_collider()
			if collider != null and collider.has_method("interact"):
				collider.interact()

	# Movement direction — zero when menus are open so the player stops cleanly
	var input_dir: Vector2 = Vector2.ZERO
	if gameplay_input_active:
		input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	_input_dir = input_dir
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var is_sprinting: bool = Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO
	var speed: float = stats.sprint_speed if is_sprinting else stats.move_speed

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

const BUILD_TOOL_SCENE: String = "res://game/actors/weapons/build_tool/build_tool.tscn"

func _on_active_slot_changed(_index: int, slot: HotbarSlotData) -> void:
	match slot.slot_type:
		HotbarSlotData.SlotType.WEAPON:
			weapon_mount.equip_weapon(slot.weapon_scene)
		HotbarSlotData.SlotType.EMPTY:
			weapon_mount.equip_weapon(null)
		HotbarSlotData.SlotType.BLOCK:
			## Block slots always equip the build tool; it reads the active slot itself
			weapon_mount.equip_weapon(load(BUILD_TOOL_SCENE) as PackedScene)

func _on_resource_gathered(type: ResourceType.Type, amount: int) -> void:
	inventory.add_resource(type, amount)

func _on_inventory_changed(type: ResourceType.Type, count: int) -> void:
	resource_count_changed.emit(type, count)

func _on_player_died() -> void:
	state_chart.send_event("player_died")
	# Main handles the game-over transition via signal routing through Level → GameRoot
	var main: Main = get_tree().current_scene as Main
	if main != null:
		main.show_game_over()

func update_rotation(rotation_input : Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

func sprint() -> void:
	_sprint_modifier = sprint_speed_mod

func walk() -> void:
	_sprint_modifier = 0.0

func crouch() -> void:
	_crouch_modifier = crouch_speed_mod
	crouch_collision.disabled = false
	standing_collision.disabled = true

func stand() -> void:
	_crouch_modifier = 0
	crouch_collision.disabled = true
	standing_collision.disabled = false

func jump() -> void:
	velocity.y += jump_velocity

func check_fall_speed() -> bool:
	if current_fall_velocity < fall_velocity_threshold:
		current_fall_velocity = 0.0
		return true
	else:
		current_fall_velocity = 0.0
		return false

func get_input_direction() -> Vector2:
	return _input_dir
