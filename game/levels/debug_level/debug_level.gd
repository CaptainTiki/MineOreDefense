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

var _core_pod: CorePod = null
var _enemy_spawning_active: bool = false
var _enemy_spawn_timer: float = 0.0
var _enemy_spawn_index: int = 0
var _night_in_progress: bool = false

func _ready() -> void:
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

	_core_pod = load(BlockPrefabs.CORE_POD).instantiate()
	_core_pod.global_position = Vector3(0.0, 1.5, -10.0)
	_core_pod.add_to_group("core_pod")
	add_child(_core_pod)
	_core_pod.hp_changed.connect(_on_core_pod_hp_changed)
	_core_pod.core_pod_destroyed.connect(_on_core_pod_destroyed)

	var combat_dummy: CombatDummy = load(COMBAT_DUMMY_SCENE).instantiate()
	combat_dummy.global_position = Vector3(0.0, 0.0, -18.0)
	add_child(combat_dummy)

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

func _on_core_pod_hp_changed(current_hp: int, max_hp: int) -> void:
	core_pod_health_changed.emit(float(current_hp) / float(max_hp))

func _on_core_pod_destroyed() -> void:
	core_pod_destroyed.emit()

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
	if _core_pod == null or not is_instance_valid(_core_pod):
		return

	var enemy: EnemyController = load(CRAWLER_SCENE).instantiate()
	enemy.global_position = ENEMY_SPAWN_POINTS[_enemy_spawn_index]
	enemy.set_attack_target(_core_pod)
	add_child(enemy)
	_enemy_spawn_index = (_enemy_spawn_index + 1) % ENEMY_SPAWN_POINTS.size()

func _clear_active_enemies() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for node: Node in enemies:
		if node is EnemyController and is_ancestor_of(node):
			node.queue_free()
