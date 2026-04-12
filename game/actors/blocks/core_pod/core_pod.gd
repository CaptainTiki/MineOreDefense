extends BlockBase
class_name CorePod

## Emitted when HP hits zero. Level catches this to trigger game over.
## Does NOT queue_free — the game over sequence owns cleanup.
signal core_pod_destroyed()

@export var mesh_instance: MeshInstance3D = null

## Override BlockBase.take_damage to suppress auto-destroy on death.
func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		core_pod_destroyed.emit()
