extends PanelContainer
class_name WaveInfoPanel

@onready var _day_label: Label = $VBox/DayLabel
@onready var _phase_label: Label = $VBox/PhaseLabel

func _ready() -> void:
	_day_label.text = "DAY 1"
	_phase_label.text = "DAWN"

func set_day(day_number: int) -> void:
	_day_label.text = "DAY %d" % day_number

func set_phase(phase_name: String) -> void:
	_phase_label.text = phase_name
