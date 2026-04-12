extends EnemyTaskState
class_name EnemySeekTaskState

func _on_seek_state_physics_processing(_delta: float) -> void:
	var target: Node3D = enemy_controller.acquire_default_target()
	if target == null:
		enemy_controller.stop_move()
		return

	enemy_controller.set_attack_target(target)
	enemy_controller.set_move_target(target)
	if enemy_controller.is_target_in_attack_range():
		enemy_controller.state_chart.send_event("onAttackRangeEntered")
