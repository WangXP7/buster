class_name FloatingText
extends RichTextLabel

var tween: Tween

func _ready() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	anchor_left = 0
	anchor_right = 0
	anchor_top = 0
	anchor_bottom = 0
	autowrap_mode = TextServer.AUTOWRAP_OFF

func setup(text_string: String, pos: Vector2, duration: float, color: Color) -> void:
	add_theme_color_override("default_color", color)
	
	text = text_string
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
	
	global_position = pos-size/2
	
	visible_ratio = 0.0
	
	tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(self, "position:y", position.y - 15, 0.3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "visible_ratio", 1.0, 0.2)
	
	var timer = MyTimer.create_repeating(duration / 2.5, 0.8)
	timer.repeated.connect(_on_repeat)
	timer.killed.connect(queue_free)

func _on_repeat():
	visible = not visible

