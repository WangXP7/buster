class_name TimeInstance
extends RefCounted

signal killed()
signal repeated()
signal completed()

var ignore_pause: bool
var realtime: bool

var total_time: float
var time_remaining: float

var decrement_ratio: float = 0
var num_repeats: int = 0
var curr_repeats: int = 0

var is_killed: bool

func _init(_time: float):
	total_time = _time
	time_remaining = _time
	is_killed = false

func update(delta):
	time_remaining -= delta

func kill():
	is_killed = true

func elapsed() -> float:
	return total_time - time_remaining

func done_repeating() -> bool:
	if num_repeats < 0: return false
	else: return curr_repeats >= num_repeats

func set_realtime() -> TimeInstance:
	realtime = true
	return self
