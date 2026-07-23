class_name CreditsPopup
extends PanelContainer

signal back()

@onready var back_btn: TextButton = %BackBtn

func _ready() -> void:
	back_btn.pressed.connect(_on_back)

func _on_back() -> void:
	back.emit()
