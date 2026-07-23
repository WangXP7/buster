extends RichTextLabel

func _ready() -> void:
	position = Vector2(4000, 4000)
	size = Vector2.ZERO
	fit_content = true
	bbcode_enabled = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF

# Get the size of the RTL if it contains the given String
func get_string_size(string: String) -> Vector2:
	text = string
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
	return size
