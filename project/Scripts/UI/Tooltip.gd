class_name Tooltip
extends ScreenControl

@onready var tooltip_label: MaxSizeRichTextLabel = %TooltipLabel


func _ready() -> void:
	resized.connect(_on_resized)

func set_text(text: String) -> void:
	rotation = 0
	scale = Vector2.ONE
	tooltip_label.reset()
	tooltip_label.text = text
	spring()
	show()

func spring() -> void:
	Springer.squash(self, -0.1, 0.3, 1, 1000, 18)
	Springer.rotate(self, 7)

func _on_resized() -> void:
	pivot_offset = size/2
