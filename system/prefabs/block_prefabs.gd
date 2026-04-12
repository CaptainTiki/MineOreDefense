extends RefCounted
class_name BlockPrefabs

const ORE_VEIN: String = "res://game/actors/blocks/veins/ore_vein.tscn"
const LIMESTONE_VEIN: String = "res://game/actors/blocks/veins/limestone_vein.tscn"
const CRYSTAL_VEIN: String = "res://game/actors/blocks/veins/crystal_vein.tscn"
const CORE_POD: String = "res://game/actors/blocks/core_pod/core_pod.tscn"

const BUILD_FAMILY_PATHS: Dictionary = {
	"Concrete Block": [
		"res://resources/build_definitions/concrete_block.tres",
		"res://resources/build_definitions/concrete_slope_block.tres",
		"res://resources/build_definitions/concrete_corner_slope_block.tres",
	],
	"Armor Block": [
		"res://resources/build_definitions/armor_block.tres",
		"res://resources/build_definitions/armor_slope_block.tres",
		"res://resources/build_definitions/armor_corner_slope_block.tres",
	],
	"Half Block": [
		"res://resources/build_definitions/half_block.tres",
		"res://resources/build_definitions/half_slope_block.tres",
		"res://resources/build_definitions/half_corner_slope_block.tres",
	],
	"Armored Half Block": [
		"res://resources/build_definitions/armored_half_block.tres",
		"res://resources/build_definitions/armored_half_slope_block.tres",
		"res://resources/build_definitions/armored_half_corner_slope_block.tres",
	],
}

static func get_build_definition(block_name: String) -> BuildDefinition:
	return get_build_variant_definition(block_name, 0)

static func get_build_variant_definition(block_name: String, variant_index: int) -> BuildDefinition:
	var paths: Array = BUILD_FAMILY_PATHS.get(block_name, [])
	if paths.is_empty():
		return null
	var resolved_index: int = posmod(variant_index, paths.size())
	var path: String = paths[resolved_index] as String
	return load(path) as BuildDefinition

static func get_build_family_size(block_name: String) -> int:
	var paths: Array = BUILD_FAMILY_PATHS.get(block_name, [])
	return paths.size()

static func get_scene_for_block(block_name: String) -> PackedScene:
	var definition: BuildDefinition = get_build_definition(block_name)
	if definition == null:
		return null
	return definition.block_scene
