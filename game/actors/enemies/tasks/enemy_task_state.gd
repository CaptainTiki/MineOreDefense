extends Node
class_name EnemyTaskState

var enemy_controller: EnemyController

func _ready() -> void:
	if %TaskStateMachine and %TaskStateMachine is EnemyTaskStateMachine:
		enemy_controller = %TaskStateMachine.enemy_controller
