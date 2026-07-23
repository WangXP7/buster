@tool
class_name OptionLine
extends HBoxContainer

signal updated(id: String, val: int)

@export var options: Array[String] = [] :
	set(val):
		options = val
		if not is_node_ready(): await ready
		rebuild_popup()

@export var _option_name: String = "" :
	set(val):
		_option_name = val
		if not is_node_ready(): await ready
		option_name_label.text = _option_name

@export var option_id: String = ""

@onready var option_name_label: Label = %OptionName
@onready var option_picker: MenuButton = %OptionPicker
@onready var popup: PopupMenu = option_picker.get_popup()


func _ready() -> void:
	popup.index_pressed.connect(_on_index_pressed)
	option_picker.mouse_entered.connect(_on_button_hovered)
	option_picker.pressed.connect(_on_button_pressed)
	rebuild_popup()

func rebuild_popup() -> void:
	popup.clear()
	for option_str: String in options:
		popup.add_item(option_str)

func _on_index_pressed(idx: int) -> void:
	set_option(idx)
	updated.emit(option_id, idx)
	SFX.play(Sound.BUTTON_CLICK)

func set_option(idx: int) -> void:
	option_picker.text = popup.get_item_text(idx)
	# TODO: Actual option functionality

func _on_button_hovered() -> void:
	SFX.play(Sound.BUTTON_HOVER, 0.2)

func _on_button_pressed() -> void:
	SFX.play(Sound.BUTTON_CLICK)

