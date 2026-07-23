@tool
class_name URLButotn
extends TextButton

@export var url: String = ""

func _ready() -> void:
	super._ready()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	OS.shell_open(url)
