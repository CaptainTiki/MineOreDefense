extends EnemyTaskState
class_name EnemyAttackTaskState

func _on_attack_state_entered() -> void:
	enemy_controller.stop_move()

func _on_attack_state_physics_processing(_delta: float) -> void:
	var target: Node3D = enemy_controller.acquire_default_target()
	if target == null:
		enemy_controller.state_chart.send_event("onAttackRangeExited")
		return

	enemy_controller.set_attack_target(target)
	enemy_controller.stop_move()
	if not enemy_controller.is_target_in_attack_range():
		enemy_controller.state_chart.send_event("onAttackRangeExited")
		return

	enemy_controller.attack_target()
