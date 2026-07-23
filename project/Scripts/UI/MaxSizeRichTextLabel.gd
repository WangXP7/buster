class_name MaxSizeRichTextLabel
extends RichTextLabel

# If label exceeds max_width, automatically change it to wrap
@export var max_width: float = 100.0


func _ready() -> void:
	resized.connect(_on_resized)

func _on_resized() -> void:
	if size.x > max_width:
		custom_minimum_size.x = max_width
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		size.x = max_width

func reset() -> void:
	custom_minimum_size.x = 0
	autowrap_mode = TextServer.AUTOWRAP_OFF
