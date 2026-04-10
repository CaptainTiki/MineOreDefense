extends Resource
class_name VeinData

@export var vein_type: ResourceType.Type = ResourceType.Type.ORE
@export var max_health: float = 100.0
## How much resource is yielded each time the damage threshold is crossed
@export var yield_per_threshold: int = 1
## Total yields before the vein is exhausted
@export var max_yield: int = 20
## How much laser damage triggers one yield event
@export var damage_per_yield: float = 5.0
