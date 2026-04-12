extends WeaponBase
class_name MiningLaserTool

@export var dps: float = 25.0
@export var max_range: float = 10.0

@onready var _laser_ray: RayCast3D = $LaserRay
@onready var _beam_visual: MeshInstance3D = $BeamVisual

var _current_vein: VeinComponent = null

func start_firing() -> void:
	_beam_visual.visible = true

func stop_firing() -> void:
	_beam_visual.visible = false
	_update_current_vein(null)

func process_fire(delta: float) -> void:
	_laser_ray.force_raycast_update()
	var hit_vein: VeinComponent = null

	if _laser_ray.is_colliding():
		var collider: Object = _laser_ray.get_collider()
		var body: Node = collider as Node
		if body != null:
			hit_vein = body.get_node_or_null("VeinComponent") as VeinComponent
		var hit_pos: Vector3 = _laser_ray.get_collision_point()
		var distance: float = _laser_ray.global_position.distance_to(hit_pos)
		_set_beam_length(distance)
		if hit_vein != null:
			hit_vein.take_damage(dps * delta)
	else:
		_set_beam_length(max_range)

	_update_current_vein(hit_vein)

func _set_beam_length(length: float) -> void:
	_beam_visual.position.z = -length / 2.0
	_beam_visual.scale.z = length

func _update_current_vein(vein: VeinComponent) -> void:
	if vein == _current_vein:
		return
	if _current_vein != null and is_instance_valid(_current_vein):
		if _current_vein.resource_yielded.is_connected(_on_resource_yielded):
			_current_vein.resource_yielded.disconnect(_on_resource_yielded)
	_current_vein = vein
	if _current_vein != null:
		_current_vein.resource_yielded.connect(_on_resource_yielded)

func _on_resource_yielded(type: ResourceType.Type, amount: int) -> void:
	resource_gathered.emit(type, amount)
