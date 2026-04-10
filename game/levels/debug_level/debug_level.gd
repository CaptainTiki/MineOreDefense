extends Level
class_name DebugLevel

@onready var player_spawn: Marker3D = $PlayerSpawn

func _ready() -> void:
	var player: PlayerController = PlayerPrefabs.player_scene.instantiate()
	player.global_position = player_spawn.global_position
	add_child(player)
	player.resource_count_changed.connect(_on_resource_count_changed)

func _on_resource_count_changed(type: ResourceType.Type, count: int) -> void:
	resource_count_changed.emit(type, count)
