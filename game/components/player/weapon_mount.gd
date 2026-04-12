extends Node3D
class_name WeaponMount

signal resource_gathered(type: ResourceType.Type, amount: int)

@export var default_weapon: PackedScene = null

var _current_weapon: WeaponBase = null

func _ready() -> void:
	if default_weapon != null:
		equip_weapon(default_weapon)

func get_weapon() -> WeaponBase:
	return _current_weapon

func equip_weapon(scene: PackedScene) -> void:
	if _current_weapon != null:
		_current_weapon.resource_gathered.disconnect(_on_resource_gathered)
		_current_weapon.unequip()
		_current_weapon.queue_free()
		_current_weapon = null
	if scene == null:
		return
	_current_weapon = scene.instantiate() as WeaponBase
	add_child(_current_weapon)
	_current_weapon.resource_gathered.connect(_on_resource_gathered)
	_current_weapon.equip()

func fire() -> void:
	if _current_weapon != null:
		_current_weapon.fire()

func fire_released() -> void:
	if _current_weapon != null:
		_current_weapon.fire_released()

func alt_fire() -> void:
	if _current_weapon != null:
		_current_weapon.alt_fire()

func reload() -> void:
	if _current_weapon != null:
		_current_weapon.reload()

func _on_resource_gathered(type: ResourceType.Type, amount: int) -> void:
	resource_gathered.emit(type, amount)
