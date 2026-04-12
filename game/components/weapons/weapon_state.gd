extends Node
class_name WeaponState

var weapon: WeaponBase

func _ready() -> void:
	if %WeaponStateMachine and %WeaponStateMachine is WeaponStateMachine:
		weapon = %WeaponStateMachine.weapon
