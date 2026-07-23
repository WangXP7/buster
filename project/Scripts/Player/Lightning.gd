class_name Lightning
extends Node2D

@onready var _exclude: Array = []

var damage: float
var max_range: float
var chain_range: float
var max_chains: int

var curr_chains: int

var color: Color = MyColors.BLUE


func load_lightning(initial_target: Enemy, _damage: float, _chain_range: float,
_max_chains: int) -> void:
	damage = _damage
	chain_range = _chain_range
	max_chains = _max_chains
	
	await process_chains(initial_target.global_position)
	
	queue_free()

func process_chains(start_pos: Vector2) -> void:
	var chain_source_pos: Vector2 = start_pos
	while curr_chains < max_chains:
		await get_tree().create_timer(0.06).timeout
		var chain_target: Enemy = _lightning_chain(chain_source_pos)
		if chain_target:
			chain_source_pos = chain_target.global_position
			_exclude.append(chain_target.get_rid())
		else:
			break
		curr_chains += 1

func _lightning_chain(pos: Vector2) -> Enemy:
	var results: Array[Dictionary] = ShapeCaster.circle_cast(
			pos, chain_range, Refs.enemy_mask, _exclude, true, false, 1)
	if not results.is_empty():
		var target: Object = results[0].collider
		if target is Enemy:
			Effects.electricity(pos, target.global_position, color)
			target.take_damage(damage)
			Effects.square_impact(target.global_position, 0, Vector2(16,16), MyColors.BLUE)
			SFX.play(Sound.ELECTRICITY)
			return target
	return null

