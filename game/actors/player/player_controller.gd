extends CharacterBody3D
class_name PlayerController

signal resource_count_changed(type: ResourceType.Type, count: int)

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var stats: PlayerStats = $PlayerStats
@onready var state_chart: StateChart = $StateChart
@onready var inventory: PlayerInventory = $PlayerInventory
@onready var _mining_laser: MiningLaserComponent = $Camera3D/WeaponMount/MiningLaser
@onready var _interaction_ray: RayCast3D = $Camera3D/InteractionRay

func _ready() -> void:
	stats.player_died.connect(_on_player_died)
	_mining_laser.resource_mined.connect(_on_resource_mined)
	inventory.inventory_changed.connect(_on_inventory_changed)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = stats.jump_velocity

	# Interact
	if Input.is_action_just_pressed("interact") and _interaction_ray.is_colliding():
		var collider: Object = _interaction_ray.get_collider()
		if collider != null and collider.has_method("interact"):
			collider.interact()

	# Movement direction relative to where the player is facing
	var input_dir: Vector2 = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var is_sprinting: bool = Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO
	var speed: float = stats.sprint_speed if is_sprinting else stats.move_speed

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	# Drive state chart
	if input_dir != Vector2.ZERO:
		if is_sprinting:
			state_chart.send_event("started_sprinting")
		else:
			state_chart.send_event("started_moving")
	else:
		state_chart.send_event("stopped_moving")
		state_chart.send_event("stopped_sprinting")

	move_and_slide()

func _on_resource_mined(type: ResourceType.Type, amount: int) -> void:
	inventory.add_resource(type, amount)

func _on_inventory_changed(type: ResourceType.Type, count: int) -> void:
	resource_count_changed.emit(type, count)

func _on_player_died() -> void:
	state_chart.send_event("player_died")
	# Main handles the game-over transition via signal routing through Level → GameRoot
	var main: Main = get_tree().current_scene as Main
	if main != null:
		main.show_game_over()
