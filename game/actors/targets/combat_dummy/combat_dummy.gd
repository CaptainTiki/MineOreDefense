extends StaticBody3D
class_name CombatDummy

@export var max_hp: int = 90
@export var reset_delay: float = 1.2
@export var mesh_instance: MeshInstance3D = null
@export var healthy_material: Material = null
@export var hit_material: Material = null

var _current_hp: int = 0
var _reset_timer: float = 0.0
var _hit_flash_timer: float = 0.0

func _ready() -> void:
	_current_hp = max_hp
	_apply_healthy_visual()

func _process(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer = max(0.0, _hit_flash_timer - delta)
		if _hit_flash_timer == 0.0:
			_apply_healthy_visual()

	if _reset_timer > 0.0:
		_reset_timer = max(0.0, _reset_timer - delta)
		if _reset_timer == 0.0:
			_current_hp = max_hp
			_apply_healthy_visual()

func take_damage(amount: int) -> void:
	_current_hp = max(0, _current_hp - amount)
	_hit_flash_timer = 0.12
	_apply_hit_visual()
	if _current_hp == 0:
		_reset_timer = reset_delay

func _apply_healthy_visual() -> void:
	if mesh_instance != null and healthy_material != null:
		mesh_instance.set_surface_override_material(0, healthy_material)

func _apply_hit_visual() -> void:
	if mesh_instance != null and hit_material != null:
		mesh_instance.set_surface_override_material(0, hit_material)
