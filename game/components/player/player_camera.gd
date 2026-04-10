extends Camera3D
class_name PlayerCamera

const MOUSE_SENSITIVITY: float = 0.002
const PITCH_MIN: float = -1.5
const PITCH_MAX: float = 1.5

var _pitch: float = 0.0

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	var motion: InputEventMouseMotion = event as InputEventMouseMotion

	# Horizontal rotation — rotate the whole body around Y
	get_parent().rotate_y(-motion.relative.x * MOUSE_SENSITIVITY)

	# Vertical rotation — tilt only the camera, clamped
	_pitch -= motion.relative.y * MOUSE_SENSITIVITY
	_pitch = clampf(_pitch, PITCH_MIN, PITCH_MAX)
	rotation.x = _pitch
