class_name FrameInstance
extends RefCounted

signal killed()
signal completed()

var ignore_pause: bool

var total_frames: int
var frames_remaining: int

var is_killed: bool

func _init(_frames):
	total_frames = _frames
	frames_remaining = _frames
	is_killed = false

func update(delta):
	frames_remaining -= 1

func kill():
	is_killed = true

func elapsed() -> int:
	return total_frames - frames_remaining

