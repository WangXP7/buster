@tool
class_name TextButton
extends MyButton

@export var btn_text: String = "" :
	set(val):
		btn_text = val
		if not is_node_ready(): await ready
		label.text = "[center]%s[/center]" % btn_text
		label.propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
		update_label_size()

@onready var label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	super._ready()
	resized.connect(_on_resized)
	label.resized.connect(update_label_size)

# Workaround for 0.5 pixel issue when centering
func update_label_size() -> void:
	if int(label.size.x) % 2 == 0:
		if label.offset_right == 0: label.offset_right = 1
		else: label.offset_right = 0

func _on_resized() -> void:
	if int(size.y) % 2 == 1:
		label.offset_top = 1
	else:
		label.offset_top = 0
