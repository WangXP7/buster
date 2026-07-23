extends Node

signal new_frame()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 999

func idle(obj: Object, method: StringName, args: Array = []) -> void:
	await new_frame
	obj.callv(method, args)

func _process(delta):
	var a = InputEventAction.new()
	a.action = "new_frame"
	a.pressed = true
	Input.parse_input_event(a)

func _input(event):
	if event.is_action_pressed("new_frame"):
		get_viewport().set_input_as_handled()
		new_frame.emit()
