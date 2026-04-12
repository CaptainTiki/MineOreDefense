extends Node3D
class_name Level

# Routed up from PlayerInventory → PlayerController → Level → GameRoot → HUD
signal resource_count_changed(type: ResourceType.Type, count: int)
# Routed up from CorePod.hp_changed → Level → GameRoot → HUD
signal core_pod_health_changed(pct: float)
# Routed up from CorePod.core_pod_destroyed → Level → GameRoot → Main
signal core_pod_destroyed()
# Routed up from DayNightCycle → Level → GameRoot → HUD
signal phase_changed(phase: int)
signal day_changed(day_number: int)
