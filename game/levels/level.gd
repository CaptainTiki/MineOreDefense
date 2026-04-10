extends Node3D
class_name Level

# Routed up from PlayerInventory → PlayerController → Level → GameRoot → HUD
signal resource_count_changed(type: ResourceType.Type, count: int)
