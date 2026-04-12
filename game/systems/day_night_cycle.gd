extends Node3D
class_name DayNightCycle

enum Phase { DAWN, DAY, DUSK, DARK, NIGHT }

## Emitted when crossing a phase boundary. Value is a DayNightCycle.Phase int.
signal phase_changed(phase: int)
## Emitted when a new day begins (NIGHT → DAWN rollover).
signal day_changed(day_number: int)

# ── Durations (seconds) ──────────────────────────────────────────────────────
@export var dawn_duration: float  = 30.0
@export var day_duration: float   = 180.0
@export var dusk_duration: float  = 30.0
@export var dark_duration: float  = 60.0    # pitch black, spawns begin
@export var night_duration: float = 180.0   # moon up, enemies visible

## Set by the level in _ready() before this node enters the scene tree.
@export var world_env: WorldEnvironment = null

# ── Node refs ────────────────────────────────────────────────────────────────
@onready var _sun:       DirectionalLight3D = $Sun
@onready var _moon:      DirectionalLight3D = $Moon
@onready var _sun_disc:  MeshInstance3D     = $SunDisc
@onready var _moon_disc: MeshInstance3D     = $MoonDisc

# ── Runtime state ─────────────────────────────────────────────────────────────
var _elapsed: float        = 0.0
var _current_day: int      = 1
var _current_phase: Phase  = Phase.DAWN
var _env: Environment      = null
var _sky_mat: ProceduralSkyMaterial = null
var _sun_mat: StandardMaterial3D    = null
var _moon_mat: StandardMaterial3D   = null

## How far (units) from the camera the disc orbs are placed.
## Far enough to sit behind terrain; well within default Camera3D far-clip of 4000.
const SKY_DIST: float = 500.0

# ── Ambient color/energy per phase ───────────────────────────────────────────
const _COL_DAY:     Color = Color(0.30, 0.25, 0.40)
const _COL_HORIZON: Color = Color(0.50, 0.22, 0.10)  # warm orange transition
const _COL_DARK:    Color = Color(0.02, 0.01, 0.04)
const _COL_NIGHT:   Color = Color(0.04, 0.06, 0.16)

const _NRG_DAY:     float = 0.40
const _NRG_HORIZON: float = 0.20
const _NRG_DARK:    float = 0.04
const _NRG_NIGHT:   float = 0.22

# ── ProceduralSkyMaterial colors per phase ───────────────────────────────────
const _SKY_TOP_DAY:    Color = Color(0.04, 0.12, 0.22)  # dark alien teal
const _SKY_HOR_DAY:    Color = Color(0.12, 0.20, 0.30)
const _SKY_TOP_HORIZ:  Color = Color(0.08, 0.06, 0.12)  # purple transition
const _SKY_HOR_HORIZ:  Color = Color(0.40, 0.16, 0.04)  # burnt orange horizon
const _SKY_TOP_DARK:   Color = Color(0.01, 0.00, 0.02)
const _SKY_HOR_DARK:   Color = Color(0.02, 0.01, 0.03)
const _SKY_TOP_NIGHT:  Color = Color(0.02, 0.01, 0.06)  # deep purple
const _SKY_HOR_NIGHT:  Color = Color(0.03, 0.02, 0.09)
const _GND_COLOR:      Color = Color(0.02, 0.03, 0.02)  # dark ground

# ── Sun light colors ─────────────────────────────────────────────────────────
const _SUN_WHITE: Color = Color(1.00, 0.97, 0.88)
const _SUN_WARM:  Color = Color(1.00, 0.60, 0.22)
const _MOON_COL:  Color = Color(0.60, 0.72, 1.00)

func _ready() -> void:
	_sun_mat  = _sun_disc.get_surface_override_material(0)  as StandardMaterial3D
	_moon_mat = _moon_disc.get_surface_override_material(0) as StandardMaterial3D

	if world_env != null:
		_env = world_env.environment.duplicate()
		world_env.environment = _env

		# Switch background to procedural sky for horizon gradient.
		# ProceduralSkyMaterial also renders an atmospheric glow halo at each
		# DirectionalLight3D position — our SphereMesh discs sit in front of it.
		_sky_mat = ProceduralSkyMaterial.new()
		_sky_mat.ground_bottom_color = _GND_COLOR
		_sky_mat.ground_horizon_color = _GND_COLOR.lerp(_SKY_HOR_DAY, 0.2)
		var sky: Sky = Sky.new()
		sky.sky_material = _sky_mat
		_env.background_mode = Environment.BG_SKY
		_env.sky = sky

		# Explicit ambient color so we control darkness in the DARK phase.
		_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR

	# Disc size in the sky material halo is driven by angular_distance on the light.
	_sun.light_angular_distance  = 2.0   # degrees — sun disc apparent radius
	_moon.light_angular_distance = 2.8   # slightly larger for the moon

	# Broadcast initial values so the HUD is correct on frame 1.
	phase_changed.emit(_current_phase)
	day_changed.emit(_current_day)

func _process(delta: float) -> void:
	_elapsed += delta
	var total: float = _total_duration()
	if _elapsed >= total:
		_elapsed -= total
		_current_day += 1
		day_changed.emit(_current_day)
	_update_cycle()

# ── Public ────────────────────────────────────────────────────────────────────

func get_phase() -> Phase:
	return _current_phase

func get_day() -> int:
	return _current_day

static func phase_label(phase: Phase) -> String:
	match phase:
		Phase.DAWN:  return "DAWN"
		Phase.DAY:   return "DAY"
		Phase.DUSK:  return "DUSK"
		Phase.DARK:  return "DARK"
		Phase.NIGHT: return "NIGHT"
	return ""

# ── Internal ──────────────────────────────────────────────────────────────────

func _total_duration() -> float:
	return dawn_duration + day_duration + dusk_duration + dark_duration + night_duration

func _update_cycle() -> void:
	var t: float = _elapsed
	var new_phase: Phase
	var phase_t: float  # 0–1 within the current phase

	if t < dawn_duration:
		new_phase = Phase.DAWN
		phase_t = t / dawn_duration
	elif t < dawn_duration + day_duration:
		new_phase = Phase.DAY
		phase_t = (t - dawn_duration) / day_duration
	elif t < dawn_duration + day_duration + dusk_duration:
		new_phase = Phase.DUSK
		phase_t = (t - dawn_duration - day_duration) / dusk_duration
	elif t < dawn_duration + day_duration + dusk_duration + dark_duration:
		new_phase = Phase.DARK
		phase_t = (t - dawn_duration - day_duration - dusk_duration) / dark_duration
	else:
		new_phase = Phase.NIGHT
		phase_t = (t - dawn_duration - day_duration - dusk_duration - dark_duration) / night_duration

	if new_phase != _current_phase:
		_current_phase = new_phase
		phase_changed.emit(_current_phase)

	_update_sun(new_phase, phase_t)
	_update_moon(new_phase, phase_t)
	if _env != null:
		_update_ambient(new_phase, phase_t)

func _update_sun(phase: Phase, phase_t: float) -> void:
	# Map elapsed time within lit phases to 0–1 across the full solar arc.
	var day_total: float = dawn_duration + day_duration + dusk_duration
	var solar_frac: float

	match phase:
		Phase.DAWN:
			solar_frac = phase_t * (dawn_duration / day_total)
		Phase.DAY:
			solar_frac = (dawn_duration + phase_t * day_duration) / day_total
		Phase.DUSK:
			solar_frac = (dawn_duration + day_duration + phase_t * dusk_duration) / day_total
		_:
			_sun.visible     = false
			_sun_disc.visible = false
			return

	_sun.visible     = true
	_sun_disc.visible = true

	# solar_angle: 0 = east horizon, PI/2 = zenith, PI = west horizon
	var solar_angle: float = solar_frac * PI
	# Tiny -Z offset keeps sun north of the E-W plane → avoids look_at singularity at zenith
	var sun_pos: Vector3 = Vector3(
		cos(solar_angle),
		maxf(sin(solar_angle), 0.001),
		-0.3
	).normalized()

	# Directional light — position is irrelevant, only rotation matters
	_sun.look_at_from_position(sun_pos * 200.0, Vector3.ZERO, Vector3.UP)
	_sun.light_energy = lerpf(0.15, 1.4, sin(solar_angle))
	match phase:
		Phase.DAWN: _sun.light_color = _SUN_WARM.lerp(_SUN_WHITE, phase_t)
		Phase.DUSK: _sun.light_color = _SUN_WHITE.lerp(_SUN_WARM, phase_t)
		_:          _sun.light_color = _SUN_WHITE

	# Visible disc — follows camera so parallax doesn't reveal fixed world position
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam != null:
		_sun_disc.global_position = cam.global_position + sun_pos * SKY_DIST

	# Disc emission: brightest at noon, dimmer at horizon with warm tint
	if _sun_mat != null:
		_sun_mat.emission_energy_multiplier = lerpf(1.5, 10.0, sin(solar_angle))
		match phase:
			Phase.DAWN: _sun_mat.emission = Color(1.0, 0.65, 0.25).lerp(Color(1.0, 0.92, 0.70), phase_t)
			Phase.DUSK: _sun_mat.emission = Color(1.0, 0.92, 0.70).lerp(Color(1.0, 0.55, 0.15), phase_t)
			_:          _sun_mat.emission = Color(1.0, 0.92, 0.70)

func _update_moon(phase: Phase, phase_t: float) -> void:
	if phase != Phase.NIGHT:
		_moon.visible      = false
		_moon_disc.visible = false
		return

	_moon.visible      = true
	_moon_disc.visible = true

	# Moon travels the opposite arc: rises in the west (where sun just set), sets east.
	# moon_arc: PI = west horizon at phase_t=0, 0 = east horizon at phase_t=1
	var moon_arc: float = PI * (1.0 - phase_t)
	var moon_pos: Vector3 = Vector3(
		cos(moon_arc),
		maxf(sin(moon_arc), 0.001),
		0.3
	).normalized()

	_moon.look_at_from_position(moon_pos * 200.0, Vector3.ZERO, Vector3.UP)
	_moon.light_color = _MOON_COL
	# Fade in over the first ~10 s — moon "rises" rather than snapping on
	var rise_t: float = minf(phase_t * (night_duration / 10.0), 1.0)
	_moon.light_energy = lerpf(0.0, 0.35, rise_t)

	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam != null:
		_moon_disc.global_position = cam.global_position + moon_pos * SKY_DIST

	if _moon_mat != null:
		_moon_mat.emission_energy_multiplier = lerpf(0.0, 4.0, rise_t)

func _update_ambient(phase: Phase, phase_t: float) -> void:
	var col: Color
	var nrg: float
	var sky_top: Color
	var sky_hor: Color

	match phase:
		Phase.DAWN:
			col     = _COL_DARK.lerp(_COL_DAY, phase_t)
			nrg     = lerpf(_NRG_DARK, _NRG_DAY, phase_t)
			sky_top = _SKY_TOP_DARK.lerp(_SKY_TOP_DAY, phase_t)
			sky_hor = _SKY_HOR_DARK.lerp(_SKY_HOR_DAY, phase_t)
		Phase.DAY:
			col     = _COL_DAY
			nrg     = _NRG_DAY
			sky_top = _SKY_TOP_DAY
			sky_hor = _SKY_HOR_DAY
		Phase.DUSK:
			# Orange blooms at the horizon during the middle of dusk
			var bloom: float = 1.0 - absf(phase_t - 0.5) * 2.0
			col     = _COL_DAY.lerp(_COL_DARK, phase_t).lerp(_COL_HORIZON, bloom * 0.5)
			nrg     = lerpf(_NRG_DAY, _NRG_DARK, phase_t)
			sky_top = _SKY_TOP_DAY.lerp(_SKY_TOP_DARK, phase_t).lerp(_SKY_TOP_HORIZ, bloom * 0.6)
			sky_hor = _SKY_HOR_DAY.lerp(_SKY_HOR_DARK, phase_t).lerp(_SKY_HOR_HORIZ, bloom * 0.9)
		Phase.DARK:
			col     = _COL_DARK
			nrg     = _NRG_DARK
			sky_top = _SKY_TOP_DARK
			sky_hor = _SKY_HOR_DARK
		Phase.NIGHT:
			var rise_t: float = minf(phase_t * 3.0, 1.0)
			col     = _COL_DARK.lerp(_COL_NIGHT, rise_t)
			nrg     = lerpf(_NRG_DARK, _NRG_NIGHT, rise_t)
			sky_top = _SKY_TOP_DARK.lerp(_SKY_TOP_NIGHT, rise_t)
			sky_hor = _SKY_HOR_DARK.lerp(_SKY_HOR_NIGHT, rise_t)
		_:
			return

	_env.ambient_light_color  = col
	_env.ambient_light_energy = nrg

	if _sky_mat != null:
		_sky_mat.sky_top_color      = sky_top
		_sky_mat.sky_horizon_color  = sky_hor
		_sky_mat.sky_energy_multiplier = nrg * 2.5
