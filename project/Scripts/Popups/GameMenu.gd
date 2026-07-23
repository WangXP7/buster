class_name GameMenu
extends PanelContainer

signal back()

@onready var main_menu_btn: TextButton = %MainMenuBtn
@onready var options_btn: TextButton = %OptionsBtn
@onready var back_btn: TextButton = %BackBtn

func _ready() -> void:
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	back_btn.pressed.connect(_on_back)

func _on_main_menu_pressed() -> void:
	Refs.main_scn.enter_main_menu()
	Saver.save_game()
	Refs.popups.pop_curr()

func _on_options_pressed() -> void:
	Refs.popups.add_popup(Refs._options.instantiate())
	Refs.popups.focus_curr()

func _on_back() -> void:
	back.emit()
