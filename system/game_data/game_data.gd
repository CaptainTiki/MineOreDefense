extends Node
class_name GameData

static var instance: GameData

var run: RunData = RunData.new()

func _ready() -> void:
	instance = self

func reset_for_new_game() -> void:
	run = RunData.new()
