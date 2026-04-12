extends WeaponState
class_name LaserFiringState

func _on_firing_state_entered() -> void:
	(weapon as MiningLaserTool).start_firing()

func _on_firing_state_physics_processing(delta: float) -> void:
	# Stop firing if button released OR a menu has taken mouse focus
	var should_stop: bool = not Input.is_action_pressed("fire") \
		or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
	if should_stop:
		weapon.state_chart.send_event("onFireReleased")
		return
	(weapon as MiningLaserTool).process_fire(delta)

func _on_firing_state_exited() -> void:
	(weapon as MiningLaserTool).stop_firing()
