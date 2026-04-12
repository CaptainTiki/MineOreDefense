extends EnemyState
class_name EnemyIdleState

func _on_idle_state_physics_processing(_delta: float) -> void:
	if enemy_controller._input_dir.length() > 0.0:
		enemy_controller.state_chart.send_event("onMoving")
