extends EnemyState
class_name EnemyWalkingState

func _on_walking_state_entered() -> void:
	enemy_controller.walk()

func _on_walking_state_physics_processing(_delta: float) -> void:
	pass
