extends EnemyState
class_name EnemyAirborneState

func _on_airborne_state_physics_processing(_delta: float) -> void:
	if enemy_controller.is_on_floor():
		enemy_controller.state_chart.send_event("onGrounded")
