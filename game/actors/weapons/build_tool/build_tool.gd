extends WeaponBase
class_name BuildTool

const GHOST_SCENE: String = "res://game/actors/weapons/build_tool/build_ghost.tscn"
const CELL_SIZE: float = 1.0
const BUILD_RANGE: float = 6.0
## Y position of the wall's centre when placed on flat ground (half of 2 m height)
const WALL_CENTER_Y: float = 1.0

var _ghost: BuildGhost = null
var _ghost_valid: bool = false
var _ghost_rotation_y: float = 0.0
var _target_block: BlockBase = null
## Collected once in _ready — excludes the player body from build raycasts
var _exclude_rids: Array[RID] = []

func _ready() -> void:
	## Walk up the scene tree and collect every PhysicsBody3D RID (player capsule etc.)
	var node: Node = get_parent()
	while node != null:
		if node is PhysicsBody3D:
			_exclude_rids.append((node as PhysicsBody3D).get_rid())
		node = node.get_parent()

	var ghost_scene: PackedScene = load(GHOST_SCENE) as PackedScene
	_ghost = ghost_scene.instantiate() as BuildGhost
	add_child(_ghost)
	_ghost.hide()

func equip() -> void:
	super.equip()
	_ghost.hide()  ## update_build() controls visibility — never flash at origin
	_set_target_block(null)

func unequip() -> void:
	super.unequip()
	_ghost.hide()
	_set_target_block(null)

## Called every physics frame by BuildIdleState via the StateChart signal.
func update_build() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z * BUILD_RANGE)

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = _exclude_rids
	var result: Dictionary = space.intersect_ray(query)

	if result.is_empty():
		_ghost.hide()
		_set_target_block(null)
		return

	## Did we hit a placeable block we can repair?
	var collider: Object = result.get("collider", null)
	var hit_block: BlockBase = collider as BlockBase
	_set_target_block(hit_block)

	if hit_block != null:
		_ghost.hide()
		return

	## Only show ghost when a block type is actually selected in the hotbar
	var block_name: String = _get_active_block_name()
	if block_name.is_empty():
		_ghost.hide()
		return

	## Terrain hit with a block selected — show placement ghost
	var hit_pos: Vector3 = result.get("position", Vector3.ZERO) as Vector3
	var hit_normal: Vector3 = result.get("normal", Vector3.UP) as Vector3
	var snapped: Vector3 = _snap_position(hit_pos, hit_normal)

	_ghost_valid = not _overlaps_block(snapped, _ghost_rotation_y)
	_ghost.global_position = snapped
	_ghost.global_rotation = Vector3(0.0, _ghost_rotation_y, 0.0)
	_ghost.set_valid(_ghost_valid)
	_ghost.show()

## Override — build tool handles fire directly; no StateChart firing state needed.
func fire() -> void:
	if _target_block != null:
		_try_repair(_target_block)
	elif _ghost_valid and _ghost != null and _ghost.visible:
		_try_place()

## Alt-fire rotates the ghost (and future placed block) by 90 degrees.
func alt_fire() -> void:
	_ghost_rotation_y += PI / 2.0

# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

func _set_target_block(block: BlockBase) -> void:
	if block == _target_block:
		return
	_target_block = block
	GameData.instance.set_target_block(block)

func _get_active_block_name() -> String:
	if GameData.instance.hotbar == null:
		return ""
	var slot: HotbarSlotData = GameData.instance.hotbar.get_active_slot()
	if slot == null or slot.slot_type != HotbarSlotData.SlotType.BLOCK:
		return ""
	return slot.block_name

func _try_place() -> void:
	var block_name: String = _get_active_block_name()
	if block_name.is_empty():
		return

	var build_inv: BuildInventory = GameData.instance.build_inventory
	if build_inv == null or build_inv.get_count(block_name) <= 0:
		return

	var block_scene: PackedScene = BlockPrefabs.get_scene_for_block(block_name)
	if block_scene == null:
		return

	build_inv.remove_item(block_name, 1)

	var block: BlockBase = block_scene.instantiate() as BlockBase
	GameRoot.instance.place_block(block)
	block.global_position = _ghost.global_position
	block.global_rotation = Vector3(0.0, _ghost_rotation_y, 0.0)

func _try_repair(block: BlockBase) -> void:
	if block.current_hp >= block.max_hp:
		return

	var cost: Dictionary = block.get_repair_cost()
	var inventory: PlayerInventory = GameData.instance.player_inventory
	if inventory == null:
		return

	var ore_cost: int  = cost.get(ResourceType.Type.ORE,       0) as int
	var lime_cost: int = cost.get(ResourceType.Type.LIMESTONE,  0) as int
	var crys_cost: int = cost.get(ResourceType.Type.CRYSTALS,   0) as int

	if inventory.get_count(ResourceType.Type.ORE)       < ore_cost:  return
	if inventory.get_count(ResourceType.Type.LIMESTONE)  < lime_cost: return
	if inventory.get_count(ResourceType.Type.CRYSTALS)   < crys_cost: return

	inventory.remove_resource(ResourceType.Type.ORE,       ore_cost)
	inventory.remove_resource(ResourceType.Type.LIMESTONE,  lime_cost)
	inventory.remove_resource(ResourceType.Type.CRYSTALS,   crys_cost)
	block.apply_repair()

## Returns true if a BlockBase already occupies the given snapped position.
## Uses the same box dimensions as the wall so the check is pixel-perfect.
func _overlaps_block(position: Vector3, rotation_y: float) -> bool:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(1.0, 2.0, 0.2)

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.from_euler(Vector3(0.0, rotation_y, 0.0)), position)
	query.exclude = _exclude_rids

	var results: Array[Dictionary] = space.intersect_shape(query)
	for entry: Dictionary in results:
		if entry.get("collider", null) is BlockBase:
			return true
	return false

func _snap_position(hit_pos: Vector3, hit_normal: Vector3) -> Vector3:
	## Step half a cell into the hit normal so we land inside the target cell,
	## then snap X and Z independently to the 1 m grid.
	var raw: Vector3 = hit_pos + hit_normal * (CELL_SIZE * 0.5)
	var snapped_x: float = round(raw.x / CELL_SIZE) * CELL_SIZE
	var snapped_z: float = round(raw.z / CELL_SIZE) * CELL_SIZE
	return Vector3(snapped_x, WALL_CENTER_Y, snapped_z)
