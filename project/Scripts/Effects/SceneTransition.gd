class_name SceneTransition
extends AnimatedSprite2D

@onready var trans_in: AnimatedSprite2D = $TransitionIn
@onready var transition_text: Label = $TransitionText

var timer: TimeInstance

func _ready() -> void:
	Refs.scene_transition = self

func transition_in(text: String) -> void:
	show()
	Globals.lock_mouse(self)
	SFX.play(Sound.TRANSITION_IN, 0)
	BGM.change_settings(0.7, 500, 0.5)
	frame = 0
	trans_in.frame = 0
	trans_in.play("default")
	
	transition_text.text = text
	transition_text.propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
	transition_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	transition_text.position = round(transition_text.position)
	transition_text.visible_ratio = 0
	transition_text.show()
	
	if timer:
		timer.kill()
	
	await MyTimer.wait(0.2)
	
	var t = create_tween()
	t.tween_property(transition_text, "visible_ratio", 1.0, 0.3)
	timer = MyTimer.create_repeating(0.04, 1, 14)
	timer.repeated.connect(_on_repeat)
	await t.finished
	await MyTimer.wait(0.4)

func _on_repeat() -> void:
	transition_text.visible = not transition_text.visible

func transition_out() -> void:
	trans_in.frame = trans_in.sprite_frames.get_frame_count("default")
	play("default")
	SFX.play(Sound.TRANSITION_OUT, 0)
	await animation_finished
	hide()
	Globals.unlock_mouse(self)

func set_color(color: Color) -> void:
	self_modulate = color
	trans_in.self_modulate = color
