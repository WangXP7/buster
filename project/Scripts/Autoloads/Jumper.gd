extends Node

# Key: target; Value: current jump tween
var offsets: Dictionary = {}

func finish(target: Node) -> void:
	if offsets.has(target):
		offsets[target].custom_step(999)

func kill(target: Node) -> void:
	if offsets.has(target):
		offsets[target].kill()

func jump(target: Node, direction: Vector2, force: float, duration: float = 0.16)\
-> Tween:
	if offsets.has(target):
		offsets[target].custom_step(999)
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if target is Node2D:
		var target_2d: Node2D = target as Node2D
		t.tween_property(target_2d, "position",
			target_2d.position + direction.normalized()*force, duration * 0.5)
		t.tween_property(target_2d, "position", target_2d.position, duration * 0.5)
	elif target is Control:
		var target_ct: Control = target as Control
		t.tween_property(target_ct, "position",
			target_ct.position + direction.normalized()*force, duration * 0.5)
		t.tween_property(target_ct, "position", target_ct.position,
			duration * 0.5)
	else:
		assert(false, "Invalid Jumper target: Not a Node2D nor a Control.")
	t.finished.connect(_remove_target.bind(target))
	offsets[target] = t
	return t

func _remove_target(target) -> void:
	offsets.erase(target)
