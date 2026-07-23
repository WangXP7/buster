class_name OptionsPopup
extends PanelContainer

signal back()

@onready var window_size: OptionLine = %WindowSize
@onready var options_vbox: VBoxContainer = %OptionsVBox

@onready var back_btn: TextButton = %BackBtn

func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	
	var resolution: Vector2i = DisplayServer.screen_get_size()
	var game_res: Vector2i = Vector2i(480, 270)
	var scale_factor: int = 1
	while game_res*scale_factor < resolution:
		scale_factor += 1
	
	var resolution_strings: Array[String] = ["fullscreen"]
	for i: int in range(1, scale_factor+1):
		resolution_strings.append("%dx%d" % [game_res.x*i,
				game_res.y*i])
	window_size.options = resolution_strings
	
	for child: Control in options_vbox.get_children():
		if child.has_signal("updated"):
			child.connect("updated", _on_option_updated)
		if child.has_method("set_option"):
			child.set_option(OptionData.get_option(child.option_id))

func _on_option_updated(option_id: String, val) -> void:
	OptionData.update_option(option_id, val)
	OptionData.apply_option(option_id, val)

func _on_back() -> void:
	back.emit()
