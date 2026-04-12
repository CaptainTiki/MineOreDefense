extends Node3D
class_name Level

signal resource_count_changed(type: ResourceType.Type, count: int)
signal core_pod_health_changed(pct: float)
signal core_pod_destroyed()
signal phase_changed(phase: int)
signal day_changed(day_number: int)
signal announcement_requested(text: String, duration: float)

var _occupied_cells: Dictionary = {}

func get_occupied_cells() -> Dictionary:
	return _occupied_cells

func world_to_cell(world_position: Vector3) -> Vector3i:
	return Vector3i(floori(world_position.x), floori(world_position.y), floori(world_position.z))

func get_candidate_root_cell(hit_position: Vector3, hit_normal: Vector3) -> Vector3i:
	return world_to_cell(hit_position + (hit_normal * 0.5))

func can_place_build(definition: BuildDefinition, root_cell: Vector3i, yaw_steps: int) -> bool:
	for cell: Vector3i in get_world_cells_for_build(definition, root_cell, yaw_steps):
		if _occupied_cells.has(cell):
			return false
	return true

func get_world_cells_for_build(definition: BuildDefinition, root_cell: Vector3i, yaw_steps: int) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	for local_cell: Vector3i in definition.footprint_cells:
		cells.append(root_cell + _rotate_cell(local_cell - definition.pivot_cell, yaw_steps))
	return cells

func get_world_position_for_build(definition: BuildDefinition, root_cell: Vector3i, yaw_steps: int) -> Vector3:
	var cells: Array[Vector3i] = get_world_cells_for_build(definition, root_cell, yaw_steps)
	var min_cell: Vector3i = cells[0]
	var max_cell: Vector3i = cells[0]
	for cell: Vector3i in cells:
		min_cell = Vector3i(min(min_cell.x, cell.x), min(min_cell.y, cell.y), min(min_cell.z, cell.z))
		max_cell = Vector3i(max(max_cell.x, cell.x), max(max_cell.y, cell.y), max(max_cell.z, cell.z))

	return Vector3(
		(float(min_cell.x + max_cell.x + 1) * 0.5),
		(float(min_cell.y + max_cell.y + 1) * 0.5),
		(float(min_cell.z + max_cell.z + 1) * 0.5)
	)

func register_placed_block(block: BlockBase, definition: BuildDefinition, root_cell: Vector3i, yaw_steps: int) -> void:
	block.root_cell = root_cell
	block.placed_yaw_steps = yaw_steps
	block.occupied_world_cells = get_world_cells_for_build(definition, root_cell, yaw_steps)
	for cell: Vector3i in block.occupied_world_cells:
		_occupied_cells[cell] = block
	if not block.block_destroyed.is_connected(_on_registered_block_destroyed):
		block.block_destroyed.connect(_on_registered_block_destroyed.bind(block))

func unregister_placed_block(block: BlockBase) -> void:
	for cell: Vector3i in block.occupied_world_cells:
		if _occupied_cells.get(cell, null) == block:
			_occupied_cells.erase(cell)
	block.occupied_world_cells.clear()

func _on_registered_block_destroyed(block: BlockBase) -> void:
	unregister_placed_block(block)

func _rotate_cell(cell: Vector3i, yaw_steps: int) -> Vector3i:
	match posmod(yaw_steps, 4):
		0:
			return cell
		1:
			return Vector3i(-cell.z, cell.y, cell.x)
		2:
			return Vector3i(-cell.x, cell.y, -cell.z)
		3:
			return Vector3i(cell.z, cell.y, -cell.x)
	return cell
