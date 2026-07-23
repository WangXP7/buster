class_name PlayerHealthBar
extends TextureProgressBar

signal health_zeroed()

@onready var health_amount_text: Label = %HealthAmountText

var died: bool = false

func setup_health(max_health: int) -> void:
	max_value = max_health
	value = max_value
	update_ui()

func gain_max_health(amount: int) -> void:
	max_value += amount

func update_ui() -> void:
	var display_val: String = "%.1f" % value
	health_amount_text.text = "%s/%d" % [display_val, max_value]

func adjust_health(amount: float) -> void:
	value += amount
	if value <= 0:
		die()

func lose_health(amount: float) -> void:
	value -= amount

func _process(delta: float) -> void:
	if died:
		value = 0
	update_ui()
	if value <= 0 and not died:
		die()

func die() -> void:
	died = true
	health_zeroed.emit()
