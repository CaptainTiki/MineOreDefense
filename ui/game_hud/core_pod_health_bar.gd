extends PanelContainer
class_name CorePodHealthBar

@onready var _health_bar: ProgressBar = $VBox/HealthBar

func _ready() -> void:
	_health_bar.value = 100.0

# Called by CorePodComponent in Phase 7 via signal routing
func set_health_percent(pct: float) -> void:
	_health_bar.value = clampf(pct * 100.0, 0.0, 100.0)
