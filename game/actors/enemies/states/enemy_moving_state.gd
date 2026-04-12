extends EnemyState
class_name EnemyMovingState

func _on_moving_state_physics_processing(_delta: float) -> void:
	var flat_velocity: Vector2 = Vector2(enemy_controller.velocity.x, enemy_controller.velocity.z)
	if enemy_controller._input_dir.length() == 0.0 and flat_velocity.length() < 0.1:
		enemy_controller.state_chart.send_event("onIdle")
