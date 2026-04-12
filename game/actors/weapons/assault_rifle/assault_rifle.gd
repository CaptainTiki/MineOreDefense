extends WeaponBase
class_name AssaultRifle

@export var damage: int = 12
@export var range: float = 120.0
@export var burst_size: int = 3
@export var burst_interval: float = 0.08
@export var burst_cooldown: float = 0.24
@export var hip_fov: float = 75.0
@export var ads_fov: float = 58.0
@export var ads_speed: float = 12.0
@export var hip_local_position: Vector3 = Vector3.ZERO
@export var ads_local_position: Vector3 = Vector3(-0.08, 0.05, 0.18)

@onready var _muzzle_point: Marker3D = $MuzzlePoint
@onready var _muzzle_flash: MeshInstance3D = $MuzzleFlash
@onready var _tracer: MeshInstance3D = $Tracer
@onready var _impact_flash: MeshInstance3D = $ImpactFlash

var _shots_remaining_in_burst: int = 0
var _burst_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _is_ads_active: bool = false
var _hip_basis: Basis = Basis.IDENTITY
var _ads_basis: Basis = Basis.from_euler(Vector3(-0.01, 0.0, 0.0))
var _tracer_timer: float = 0.0
var _impact_timer: float = 0.0
var _flash_timer: float = 0.0

func _ready() -> void:
	position = hip_local_position
	_muzzle_flash.visible = false
	_tracer.visible = false
	_impact_flash.visible = false

func _process(delta: float) -> void:
	_update_ads(delta)
	_update_feedback_timers(delta)

func _physics_process(delta: float) -> void:
	_cooldown_timer = max(0.0, _cooldown_timer - delta)
	if _shots_remaining_in_burst <= 0:
		return

	_burst_timer -= delta
	if _burst_timer > 0.0:
		return

	_fire_single_shot()
	_shots_remaining_in_burst -= 1
	if _shots_remaining_in_burst > 0:
		_burst_timer = burst_interval
	else:
		_cooldown_timer = burst_cooldown

func equip() -> void:
	super.equip()
	_is_ads_active = false
	_reset_camera_fov()

func unequip() -> void:
	super.unequip()
	_is_ads_active = false
	_shots_remaining_in_burst = 0
	_muzzle_flash.visible = false
	_tracer.visible = false
	_impact_flash.visible = false
	_reset_camera_fov()

func fire() -> void:
	if _shots_remaining_in_burst > 0 or _cooldown_timer > 0.0:
		return
	_shots_remaining_in_burst = burst_size
	_burst_timer = 0.0

func alt_fire() -> void:
	_is_ads_active = true

func alt_fire_released() -> void:
	_is_ads_active = false

func _fire_single_shot() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var screen_center: Vector2 = viewport_size * 0.5
	var ray_origin: Vector3 = camera.project_ray_origin(screen_center)
	var ray_end: Vector3 = ray_origin + (camera.project_ray_normal(screen_center) * range)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)

	var exclude: Array[RID] = []
	var player_rid: RID = _get_player_rid()
	if player_rid.is_valid():
		exclude.append(player_rid)
	query.exclude = exclude

	var hit_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	var target_point: Vector3 = ray_end
	var hit_normal: Vector3 = Vector3.ZERO

	if not hit_result.is_empty():
		target_point = hit_result.get("position", ray_end) as Vector3
		hit_normal = hit_result.get("normal", Vector3.ZERO) as Vector3
		var collider: Object = hit_result.get("collider", null)
		var target: Node = _find_damage_target(collider as Node)
		if target != null and target.has_method("take_damage"):
			target.call("take_damage", damage)

	_show_shot_feedback(target_point, hit_normal)

func _show_shot_feedback(hit_point: Vector3, hit_normal: Vector3) -> void:
	_muzzle_flash.visible = true
	_flash_timer = 0.05

	var tracer_distance: float = _muzzle_point.global_position.distance_to(hit_point)
	_tracer.visible = true
	_tracer_timer = 0.05
	_tracer.position = Vector3(_muzzle_point.position.x, _muzzle_point.position.y, -tracer_distance * 0.5)
	_tracer.scale = Vector3(1.0, 1.0, tracer_distance)

	_impact_flash.visible = true
	_impact_flash.global_position = hit_point + (hit_normal * 0.03)
	if hit_normal != Vector3.ZERO:
		_impact_flash.look_at(_impact_flash.global_position + hit_normal, Vector3.UP)
	_impact_timer = 0.08

func _update_ads(delta: float) -> void:
	var target_position: Vector3 = ads_local_position if _is_ads_active else hip_local_position
	var target_basis: Basis = _ads_basis if _is_ads_active else _hip_basis
	var t: float = min(1.0, delta * ads_speed)
	position = position.lerp(target_position, t)
	basis = basis.slerp(target_basis, t)

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera != null:
		var target_fov: float = ads_fov if _is_ads_active else hip_fov
		camera.fov = lerpf(camera.fov, target_fov, t)

func _update_feedback_timers(delta: float) -> void:
	_flash_timer -= delta
	if _flash_timer <= 0.0:
		_muzzle_flash.visible = false

	_tracer_timer -= delta
	if _tracer_timer <= 0.0:
		_tracer.visible = false

	_impact_timer -= delta
	if _impact_timer <= 0.0:
		_impact_flash.visible = false

func _reset_camera_fov() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera != null:
		camera.fov = hip_fov

func _get_player_rid() -> RID:
	var node: Node = get_parent()
	while node != null:
		if node is PhysicsBody3D:
			return (node as PhysicsBody3D).get_rid()
		node = node.get_parent()
	return RID()

func _find_damage_target(node: Node) -> Node:
	var current: Node = node
	while current != null:
		if current.has_method("take_damage"):
			return current
		current = current.get_parent()
	return null
