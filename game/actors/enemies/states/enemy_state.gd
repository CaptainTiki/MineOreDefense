extends Node
class_name EnemyState

var enemy_controller: EnemyController

func _ready() -> void:
	if %MovementStateMachine and %MovementStateMachine is EnemyStateMachine:
		enemy_controller = %MovementStateMachine.enemy_controller
