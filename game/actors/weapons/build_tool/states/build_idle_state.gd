extends WeaponState
class_name BuildIdleState

func _on_idle_state_physics_processing(_delta: float) -> void:
	(weapon as BuildTool).update_build()
