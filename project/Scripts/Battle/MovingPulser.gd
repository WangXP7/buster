class_name MovingPulser
extends Node2D

@onready var bar: TextureProgressBar = %TextureProgressBar

var curr_target: Enemy

var curr_destination: Vector2
var curr_rangle: float = randf_range(0, TAU)
var speed: float = 15
var turn_speed: float = PI/2

func _ready() -> void:
	bar.modulate = MyColors.BLUE
	bar.max_value = 3.0 / (1+State.stats.auto_pulser_attack_speed_mod)
	bar.value = randf_range(0.0, bar.max_value/2.0)
	bar.pivot_offset = bar.size/2
	
	speed *= 1+State.stats.auto_pulser_speed_mod

func _process(delta: float) -> void:
	if not Refs.curr_scn.battle_over:
		bar.value += delta
		if bar.value >= bar.max_value:
			bar.value = 0
			pulse()
	
	if curr_target and is_instance_valid(curr_target):
		curr_destination = curr_target.global_position
	else:
		curr_target = Refs.enemy_spawner.get_random_enemy()
	
	var target_rangle: float = global_position.direction_to(curr_destination).angle()
	var turn_dir: float = sign(angle_difference(curr_rangle, target_rangle))
	curr_rangle += turn_speed*delta*turn_dir
	
	global_position += Vector2.from_angle(curr_rangle)*speed*delta

func pulse() -> void:
	var size: float = 76 * (1+State.stats.auto_pulser_size_mod)
	Globals.create_explosion(global_position, 45, size)
	Springer.scale(bar, 0.4)
	bar.modulate = MyColors.WHITE
	await MyTimer.wait(0.1)
	bar.modulate = MyColors.BLUE

