extends WeaponBase
class_name BuildTool

const GHOST_SCENE: String = "res://game/actors/weapons/build_tool/build_ghost.tscn"
const BUILD_RANGE: float = 6.0

var _ghost: BuildGhost = null
var _ghost_valid: bool = false
var _ghost_basis: Basis = Basis.IDENTITY
var _family_variant_indices: Dictionary = {}
var _target_block: BlockBase = null
var _target_definition: BuildDefinition = null
var _target_root_cell: Vector3i = Vector3i.ZERO
var _exclude_rids: Array[RID] = []

func _ready() -> void:
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
	_ghost.hide()
	_set_target_block(null)

func unequip() -> void:
	super.unequip()
	_ghost.hide()
	_set_target_block(null)

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo or key_event.alt_pressed:
			return

		var resolved_keycode: Key = key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
		match resolved_keycode:
			KEY_LEFT:
				_rotate_local(Vector3.UP, PI * 0.5)
			KEY_RIGHT:
				_rotate_local(Vector3.UP, -PI * 0.5)
			KEY_UP:
				_rotate_local(Vector3.RIGHT, -PI * 0.5)
			KEY_DOWN:
				_rotate_local(Vector3.RIGHT, PI * 0.5)
			KEY_PAGEUP:
				_rotate_local(Vector3.BACK, PI * 0.5)
			KEY_PAGEDOWN:
				_rotate_local(Vector3.BACK, -PI * 0.5)
			_:
				return
		get_viewport().set_input_as_handled()
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	var alt_cycle_active: bool = mouse_event.alt_pressed or Input.is_key_pressed(KEY_ALT)
	if not mouse_event.pressed or not alt_cycle_active:
		return

	var family_name: String = _get_active_block_name()
	if family_name.is_empty():
		return

	if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_cycle_variant(family_name, -1)
		get_viewport().set_input_as_handled()
	elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_cycle_variant(family_name, 1)
		get_viewport().set_input_as_handled()

func update_build() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var level: Level = GameRoot.instance.get_active_level()
	if camera == null or level == null:
		return

	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + (-camera.global_transform.basis.z * BUILD_RANGE)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = _exclude_rids
	var result: Dictionary = space.intersect_ray(query)

	if result.is_empty():
		_target_definition = null
		_ghost.hide()
		_set_target_block(null)
		return

	var block_name: String = _get_active_block_name()
	var collider: Object = result.get("collider", null)
	var hit_block: BlockBase = collider as BlockBase
	_set_target_block(hit_block)

	if block_name.is_empty():
		_target_definition = null
		_ghost.hide()
		return

	var definition: BuildDefinition = BlockPrefabs.get_build_variant_definition(block_name, _get_variant_index(block_name))
	if definition == null:
		_target_definition = null
		_ghost.hide()
		return

	var hit_pos: Vector3 = result.get("position", Vector3.ZERO) as Vector3
	var hit_normal: Vector3 = result.get("normal", Vector3.UP) as Vector3
	var root_cell: Vector3i = level.get_candidate_root_cell(hit_pos, hit_normal)
	var yaw_steps: int = _get_yaw_steps()
	var ghost_position: Vector3 = level.get_world_position_for_build(definition, root_cell, yaw_steps)
	var rotation_basis: Basis = _get_preview_basis(definition)

	_target_definition = definition
	_target_root_cell = root_cell
	_ghost_valid = level.can_place_build(definition, root_cell, yaw_steps)
	_ghost.set_definition(definition)
	_ghost.set_size(definition.preview_size)
	_ghost.global_position = ghost_position + (rotation_basis * definition.preview_offset)
	_ghost.global_basis = rotation_basis
	_ghost.set_valid(_ghost_valid)
	_ghost.show()

func fire() -> void:
	if _ghost_valid and _ghost != null and _ghost.visible and _target_definition != null:
		_try_place()
	elif _target_block != null:
		_try_repair(_target_block)

func alt_fire() -> void:
	pass

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
	var build_inv: BuildInventory = GameData.instance.build_inventory
	var level: Level = GameRoot.instance.get_active_level()
	if _target_definition == null or build_inv == null or level == null:
		return
	var family_name: String = _get_active_block_name()
	if family_name.is_empty():
		return
	if build_inv.get_count(family_name) <= 0:
		return

	var yaw_steps: int = _get_yaw_steps()
	if not level.can_place_build(_target_definition, _target_root_cell, yaw_steps):
		return

	var block: BlockBase = _target_definition.block_scene.instantiate() as BlockBase
	if block == null:
		return

	var block_position: Vector3 = level.get_world_position_for_build(_target_definition, _target_root_cell, yaw_steps)
	var block_basis: Basis = _get_preview_basis(_target_definition)

	build_inv.remove_item(family_name, 1)
	GameRoot.instance.place_block(block)
	block.global_position = block_position
	block.global_basis = block_basis
	level.register_placed_block(block, _target_definition, _target_root_cell, yaw_steps)

func _try_repair(block: BlockBase) -> void:
	if block.current_hp >= block.max_hp:
		return

	var cost: Dictionary = block.get_repair_cost()
	var inventory: PlayerInventory = GameData.instance.player_inventory
	if inventory == null:
		return

	var ore_cost: int = cost.get(ResourceType.Type.ORE, 0) as int
	var lime_cost: int = cost.get(ResourceType.Type.LIMESTONE, 0) as int
	var crys_cost: int = cost.get(ResourceType.Type.CRYSTALS, 0) as int

	if inventory.get_count(ResourceType.Type.ORE) < ore_cost:
		return
	if inventory.get_count(ResourceType.Type.LIMESTONE) < lime_cost:
		return
	if inventory.get_count(ResourceType.Type.CRYSTALS) < crys_cost:
		return

	inventory.remove_resource(ResourceType.Type.ORE, ore_cost)
	inventory.remove_resource(ResourceType.Type.LIMESTONE, lime_cost)
	inventory.remove_resource(ResourceType.Type.CRYSTALS, crys_cost)
	block.apply_repair()

func _rotate_global(axis: Vector3, angle: float) -> void:
	_ghost_basis = (Basis(axis, angle) * _ghost_basis).orthonormalized()

func _rotate_local(axis: Vector3, angle: float) -> void:
	_ghost_basis = (_ghost_basis * Basis(axis, angle)).orthonormalized()

func _get_preview_basis(definition: BuildDefinition) -> Basis:
	if definition.full_rotation_supported:
		return _ghost_basis
	if definition.yaw_rotations_supported:
		return Basis(Vector3.UP, _get_yaw_steps() * PI * 0.5)
	return Basis.IDENTITY

func _get_yaw_steps() -> int:
	var forward: Vector3 = -_ghost_basis.z
	var flattened: Vector2 = Vector2(forward.x, forward.z)
	if flattened.length_squared() <= 0.001:
		return 0

	var heading: Vector2 = flattened.normalized()
	var candidates: Array[Vector2] = [
		Vector2(0.0, -1.0),
		Vector2(-1.0, 0.0),
		Vector2(0.0, 1.0),
		Vector2(1.0, 0.0),
	]
	var best_index: int = 0
	var best_dot: float = -INF
	for index: int in range(candidates.size()):
		var dot_value: float = heading.dot(candidates[index])
		if dot_value > best_dot:
			best_dot = dot_value
			best_index = index
	return best_index

func _get_variant_index(family_name: String) -> int:
	return _family_variant_indices.get(family_name, 0) as int

func _cycle_variant(family_name: String, direction: int) -> void:
	var family_size: int = BlockPrefabs.get_build_family_size(family_name)
	if family_size <= 1:
		return
	var current_index: int = _get_variant_index(family_name)
	var next_index: int = posmod(current_index + direction, family_size)
	_family_variant_indices[family_name] = next_index

	var level: Level = GameRoot.instance.get_active_level()
	var definition: BuildDefinition = BlockPrefabs.get_build_variant_definition(family_name, next_index)
	if level != null and definition != null:
		level.announcement_requested.emit(definition.display_name, 0.9)
