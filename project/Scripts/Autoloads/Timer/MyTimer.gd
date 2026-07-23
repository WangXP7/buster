extends Node

var timers: Array = []
var physics_frame_timers: Array = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	var realtime_delta: float = delta / Engine.time_scale
	var paused: bool = get_tree().paused
	
	for i in range(timers.size() - 1, -1, -1):
		if paused and not timers[i].ignore_pause:
			continue
		if timers[i].realtime: timers[i].update(realtime_delta)
		else: timers[i].update(delta)
		if timers[i].is_killed:
			timers[i].killed.emit()
			timers.remove_at(i)
		elif timers[i].time_remaining <= 0:
			timers[i].total_time *= timers[i].decrement_ratio
			if timers[i].total_time <= 0.0167 or timers[i].done_repeating():
				timers[i].killed.emit()
				timers[i].completed.emit()
				timers.remove_at(i)
			else:
				timers[i].time_remaining = timers[i].total_time
				timers[i].curr_repeats += 1
				timers[i].repeated.emit()

func create(time: float, ignore_pause: bool = false) -> TimeInstance:
	var timer = TimeInstance.new(time)
	timer.ignore_pause = ignore_pause
	timers.append(timer)
	return timer

# Easier way to await some time instead of needed to manually await completed signal
func wait(time: float, ignore_pause: bool = false) -> void:
	await create(time, ignore_pause).completed

func create_on_complete(time: float, method: Callable) -> TimeInstance:
	var timer = create(time)
	timer.on_complete.connect(method)
	return timer

# Repeating timer that emits after 'time' seconds.
# Decrement_ratio sets ratio to decrease 'time' by with each emission
# If decrement_ratio >= 1, then timer won't be naturally stopped ever!
# (unless num_repeats is specified)
func create_repeating(time: float, decrement_ratio: float,
num_repeats: int = -1) -> TimeInstance:
	var timer = TimeInstance.new(time)
	timer.num_repeats = num_repeats
	timer.decrement_ratio = decrement_ratio
	timers.append(timer)
	return timer

func _physics_process(delta):
	for i in range(physics_frame_timers.size() - 1, -1, -1):
		var timer: FrameInstance = physics_frame_timers[i]
		timer.update(delta)
		if timer.is_killed:
			timer.killed.emit()
			physics_frame_timers.remove_at(i)
		elif timer.frames_remaining <= 0:
			timer.killed.emit()
			timer.completed.emit()
			physics_frame_timers.remove_at(i)

# Timer that emits after some amount of physics frames
func create_physics_frame(frames: int) -> FrameInstance:
	var timer = FrameInstance.new(frames)
	physics_frame_timers.append(timer)
	return timer

