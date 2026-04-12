extends RefCounted
class_name BlockPrefabs

# when adding new - use paths, if godot has not generated a UID yet.
# do not use \ switches

const ORE_VEIN: String      = "res://game/actors/blocks/veins/ore_vein.tscn"
const LIMESTONE_VEIN: String = "res://game/actors/blocks/veins/limestone_vein.tscn"
const CRYSTAL_VEIN: String  = "res://game/actors/blocks/veins/crystal_vein.tscn"
const WALL: String          = "res://game/actors/blocks/wall/wall.tscn"

## Returns the PackedScene for a given recipe display_name, or null if unknown.
static func get_scene_for_block(block_name: String) -> PackedScene:
	match block_name:
		"Wall Segment":
			return load(WALL) as PackedScene
		_:
			return null
