extends Level
class_name DebugLevel

@onready var player_spawn: Marker3D = $PlayerSpawn

func _ready() -> void:
	var player: PlayerController = PlayerPrefabs.player_scene.instantiate()
	player.global_position = player_spawn.global_position
	add_child(player)
