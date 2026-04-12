extends CharacterBody3D
class_name EnemyController

signal enemy_died(enemy: EnemyController)

@export var state_chart: StateChart
@export var mesh_instance: MeshInstance3D
@export var move_speed: float = 3.5
@export var attack_range: float = 2.2
@export var attack_damage: int = 8
@export var attack_interval: float = 1.0
@export var max_health: int = 36
@export var turn_speed: float = 8.0

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _input_dir: Vector3 = Vector3.ZERO
var _move_target: Node3D = null
var _attack_target: Node3D = null
var _attack_cooldown: float = 0.0
var _current_health: int = 0

func _ready() -> void:
	_current_health = max_health
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	_attack_cooldown = max(0.0, _attack_cooldown - delta)

	if not is_on_floor():
		velocity.y -= _gravity * delta

	_update_move_direction()
	_apply_movement(delta)
	_update_facing(delta)
	move_and_slide()

func walk() -> void:
	pass

func set_move_target(target: Node3D) -> void:
	_move_target = target

func stop_move() -> void:
	_move_target = null
	_input_dir = Vector3.ZERO

func set_attack_target(target: Node3D) -> void:
	_attack_target = target

func get_attack_target() -> Node3D:
	return _attack_target

func acquire_default_target() -> Node3D:
	if is_instance_valid(_attack_target):
		return _attack_target
	var core_pod: Node = get_tree().get_first_node_in_group("core_pod")
	_attack_target = core_pod as Node3D
	return _attack_target

func has_valid_attack_target() -> bool:
	return is_instance_valid(_attack_target)

func is_target_in_attack_range() -> bool:
	if not has_valid_attack_target():
		return false
	return global_position.distance_to(_attack_target.global_position) <= attack_range

func attack_target() -> void:
	if not has_valid_attack_target():
		return
	if _attack_cooldown > 0.0:
		return
	if _attack_target.has_method("take_damage"):
		_attack_target.call("take_damage", attack_damage)
	_attack_cooldown = attack_interval

func take_damage(amount: int) -> void:
	_current_health = max(0, _current_health - amount)
	if _current_health == 0:
		die()

func die() -> void:
	enemy_died.emit(self)
	queue_free()

func _update_move_direction() -> void:
	if not is_instance_valid(_move_target):
		_input_dir = Vector3.ZERO
		return

	var to_target: Vector3 = _move_target.global_position - global_position
	to_target.y = 0.0
	_input_dir = to_target.normalized() if to_target.length() > 0.05 else Vector3.ZERO

func _apply_movement(_delta: float) -> void:
	if _input_dir == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)
		return

	velocity.x = _input_dir.x * move_speed
	velocity.z = _input_dir.z * move_speed

func _update_facing(delta: float) -> void:
	if _input_dir == Vector3.ZERO:
		return

	var target_yaw: float = atan2(-_input_dir.x, -_input_dir.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, min(1.0, delta * turn_speed))
