extends Node
class_name PlayerStats

signal player_died()

@export var stats_resource: PlayerStatsResource

var max_health: float = 100.0
var current_health: float = 100.0
var move_speed: float = 5.0
var sprint_speed: float = 8.0
var jump_velocity: float = 5.0

func _ready() -> void:
	if stats_resource == null:
		return
	max_health = stats_resource.max_health
	current_health = stats_resource.max_health
	move_speed = stats_resource.move_speed
	sprint_speed = stats_resource.sprint_speed
	jump_velocity = stats_resource.jump_velocity

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0.0:
		current_health = 0.0
		player_died.emit()

func heal(amount: float) -> void:
	current_health = minf(current_health + amount, max_health)
