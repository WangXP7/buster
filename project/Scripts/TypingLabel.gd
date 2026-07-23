class_name TypingLabel
extends Label

@onready var curr_visible: int = visible_characters

func _process(delta: float) -> void:
	if visible_characters > curr_visible:
		SFX.play(Sound.TYPE, 0.1, 0, 0, 3)
	curr_visible = visible_characters
