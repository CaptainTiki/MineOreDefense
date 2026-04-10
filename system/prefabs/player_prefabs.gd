extends RefCounted
class_name PlayerPrefabs

# when adding new - use paths, if godot has not generated a UID yet.
# do not use \ switches

#Player Prefabs
static var player_scene: PackedScene = load("res://game/actors/player/player.tscn")
