@tool
extends Level
class_name DebugLevel

const COMBAT_DUMMY_SCENE: String = "res://game/actors/targets/combat_dummy/combat_dummy.tscn"
const CRAWLER_SCENE: String = "res://game/actors/enemies/crawler/crawler.tscn"
const ENEMY_SPAWN_INTERVAL: float = 8.0
const ENEMY_SPAWN_POINTS: Array[Vector3] = [
	Vector3(0.0, 5.0, -26.0),
	Vector3(14.0, 5.0, -18.0),
	Vector3(-14.0, 5.0, -18.0),
	Vector3(10.0, 5.0, 12.0),
]

@onready var _player_spawn: Marker3D = $PlayerSpawn
@onready var _world_env: WorldEnvironment = $WorldEnvironment
@onready var _placeholder_sun: DirectionalLight3D = $DirectionalLight3D
@onready var _terrain: DebugTerrainHeightmap = $Ground
@onready var _fabricator: FabricatorDevice = $FabricatorDevice
@onready var _veins_root: Node3D = $Veins

var _enemy_spawning_active: bool = false
var _enemy_spawn_timer: float = 0.0
var _enemy_spawn_index: int = 0
var _night_in_progress: bool = false
var _editor_layout_queued: bool = false

func _ready() -> void:
	if not _terrain.terrain_rebuilt.is_connected(_on_terrain_rebuilt):
		_terrain.terrain_rebuilt.connect(_on_terrain_rebuilt)
	_layout_level_markers()

	if Engine.is_editor_hint():
		return

	# Hand lighting over to DayNightCycle
	_placeholder_sun.visible = false

	var dnc: DayNightCycle = load("res://game/systems/day_night_cycle.tscn").instantiate()
	dnc.world_env = _world_env
	add_child(dnc)
	dnc.phase_changed.connect(_on_phase_changed)
	dnc.day_changed.connect(_on_day_changed)

	var player: PlayerController = PlayerPrefabs.player_scene.instantiate()
	player.global_position = _player_spawn.global_position
	add_child(player)
	GameData.instance.player_inventory = player.inventory
	GameData.instance.build_inventory = player.build_inventory
	GameData.instance.set_hotbar(player.hotbar)
	player.resource_count_changed.connect(_on_resource_count_changed)
	player.build_inventory.add_item("Core Pod", 1)
	call_deferred("_announce_core_pod_setup")

	var combat_dummy: CombatDummy = load(COMBAT_DUMMY_SCENE).instantiate()
	combat_dummy.global_position = _grounded_position(Vector3(0.0, 0.0, -18.0), 0.0)
	add_child(combat_dummy)

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
	if what == NOTIFICATION_READY or what == NOTIFICATION_ENTER_TREE:
		_queue_editor_layout()

func _queue_editor_layout() -> void:
	if _editor_layout_queued:
		return
	_editor_layout_queued = true
	call_deferred("_refresh_editor_layout")

func _refresh_editor_layout() -> void:
	_editor_layout_queued = false
	if not is_inside_tree():
		return
	_layout_level_markers()

func _on_terrain_rebuilt() -> void:
	_layout_level_markers()

func _process(delta: float) -> void:
	if not _enemy_spawning_active:
		return

	_enemy_spawn_timer -= delta
	if _enemy_spawn_timer > 0.0:
		return

	_spawn_enemy()
	_enemy_spawn_timer = ENEMY_SPAWN_INTERVAL

func _on_resource_count_changed(type: ResourceType.Type, count: int) -> void:
	resource_count_changed.emit(type, count)

func _on_phase_changed(phase: int) -> void:
	var cycle_phase: DayNightCycle.Phase = phase as DayNightCycle.Phase
	var hostile_phase: bool = cycle_phase == DayNightCycle.Phase.DARK or cycle_phase == DayNightCycle.Phase.NIGHT

	if hostile_phase and not _night_in_progress:
		_night_in_progress = true
		announcement_requested.emit("NIGHTFALL - DEFEND THE CORE", 2.4)

	if not hostile_phase and _night_in_progress:
		_night_in_progress = false
		_enemy_spawning_active = false
		_enemy_spawn_timer = 0.0
		_clear_active_enemies()
		announcement_requested.emit("DAWN REACHED - NIGHT SURVIVED", 2.8)

	_enemy_spawning_active = hostile_phase
	if _enemy_spawning_active and _enemy_spawn_timer <= 0.0:
		_enemy_spawn_timer = 0.5
	phase_changed.emit(phase)

func _on_day_changed(day: int) -> void:
	day_changed.emit(day)

func _spawn_enemy() -> void:
	var core_pod: CorePod = get_core_pod()
	if core_pod == null or not is_instance_valid(core_pod):
		return

	var enemy: EnemyController = load(CRAWLER_SCENE).instantiate()
	enemy.global_position = ENEMY_SPAWN_POINTS[_enemy_spawn_index]
	enemy.set_attack_target(core_pod)
	add_child(enemy)
	_enemy_spawn_index = (_enemy_spawn_index + 1) % ENEMY_SPAWN_POINTS.size()

func _clear_active_enemies() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for node: Node in enemies:
		if node is EnemyController and is_ancestor_of(node):
			node.queue_free()

func _announce_core_pod_setup() -> void:
	announcement_requested.emit("TAB: DRAG CORE POD TO A HOTBAR SLOT, THEN PLACE YOUR BASE", 4.0)

func _layout_level_markers() -> void:
	_player_spawn.position = _grounded_position(Vector3(0.0, 0.0, 28.0), 1.0)
	_fabricator.position = _grounded_position(Vector3(8.0, 0.0, 18.0), 1.0)

	var desired_positions: Dictionary = {
		"OreVein1": Vector3(-12.0, 0.0, 16.0),
		"OreVein2": Vector3(15.0, 0.0, 12.0),
		"OreVein3": Vector3(-6.0, 0.0, 0.0),
		"LimestoneVein1": Vector3(-36.0, 0.0, 8.0),
		"LimestoneVein2": Vector3(31.0, 0.0, 12.0),
		"CrystalVein1": Vector3(-18.0, 0.0, -40.0),
		"CrystalVein2": Vector3(18.0, 0.0, -44.0),
	}

	for node: Node in _veins_root.get_children():
		if not node is Node3D:
			continue
		var node3d: Node3D = node as Node3D
		if desired_positions.has(node3d.name):
			node3d.position = _grounded_position(desired_positions[node3d.name] as Vector3, 0.0)

func _grounded_position(position: Vector3, y_offset: float) -> Vector3:
	var height: float = _terrain.sample_height(position.x, position.z)
	return Vector3(position.x, height + y_offset, position.z)
