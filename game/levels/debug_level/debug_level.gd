extends Level
class_name DebugLevel

const COMBAT_DUMMY_SCENE: String = "res://game/actors/targets/combat_dummy/combat_dummy.tscn"

@onready var _player_spawn: Marker3D = $PlayerSpawn
@onready var _world_env: WorldEnvironment = $WorldEnvironment
@onready var _placeholder_sun: DirectionalLight3D = $DirectionalLight3D

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

	var core_pod: CorePod = load(BlockPrefabs.CORE_POD).instantiate()
	core_pod.global_position = Vector3(0.0, 1.5, -10.0)
	add_child(core_pod)
	core_pod.hp_changed.connect(_on_core_pod_hp_changed)
	core_pod.core_pod_destroyed.connect(_on_core_pod_destroyed)

	var combat_dummy: CombatDummy = load(COMBAT_DUMMY_SCENE).instantiate()
	combat_dummy.global_position = Vector3(0.0, 0.0, -18.0)
	add_child(combat_dummy)

func _on_resource_count_changed(type: ResourceType.Type, count: int) -> void:
	resource_count_changed.emit(type, count)

func _on_core_pod_hp_changed(current_hp: int, max_hp: int) -> void:
	core_pod_health_changed.emit(float(current_hp) / float(max_hp))

func _on_core_pod_destroyed() -> void:
	core_pod_destroyed.emit()

func _on_phase_changed(phase: int) -> void:
	phase_changed.emit(phase)

func _on_day_changed(day: int) -> void:
	day_changed.emit(day)
