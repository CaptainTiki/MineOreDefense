extends Node3D
class_name WeaponBase

signal resource_gathered(type: ResourceType.Type, amount: int)

@export var weapon_name: String = ""
@export var state_chart: StateChart

func equip() -> void:
	show()

func unequip() -> void:
	hide()

func fire() -> void:
	if state_chart != null:
		state_chart.send_event("onFire")

func fire_released() -> void:
	if state_chart != null:
		state_chart.send_event("onFireReleased")

func alt_fire() -> void:
	if state_chart != null:
		state_chart.send_event("onAltFire")

func alt_fire_released() -> void:
	if state_chart != null:
		state_chart.send_event("onAltFireReleased")

func reload() -> void:
	if state_chart != null:
		state_chart.send_event("onReload")
