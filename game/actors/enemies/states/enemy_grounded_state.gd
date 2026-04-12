extends EnemyState
class_name EnemyGroundedState

func _on_grounded_state_physics_processing(_delta: float) -> void:
	if not enemy_controller.is_on_floor():
		enemy_controller.state_chart.send_event("onAirborne")
