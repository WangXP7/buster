@tool
class_name OptionSlider
extends HBoxContainer

signal updated(id: String, val: int)

@export var _option_name: String = "" :
	set(val):
		_option_name = val
		if not is_node_ready(): await ready
		option_name_label.text = _option_name

@export var option_id: String = ""

@onready var option_name_label: Label = %OptionName
@onready var slider: HSlider = %HSlider
@onready var slider_val: Label = %SliderVal

func _ready() -> void:
	slider.value_changed.connect(_on_slider_value_changed)
	slider.mouse_entered.connect(_on_slider_hovered)
	slider.drag_started.connect(_on_drag_started)
	slider.drag_ended.connect(_on_drag_ended)

func _on_slider_value_changed(value: float) -> void:
	slider_val.text = str(value)
	updated.emit(option_id, int(value))

func set_option(val: int) -> void:
	slider.value = val

func _on_slider_hovered() -> void:
	SFX.play(Sound.BUTTON_HOVER, 0.2)

func _on_drag_started() -> void:
	Globals.lock_mouse(self)
	SFX.play(Sound.BUTTON_DOWN)

func _on_drag_ended(value_changed: bool) -> void:
	Globals.unlock_mouse(self)
	SFX.play(Sound.BUTTON_UP)
