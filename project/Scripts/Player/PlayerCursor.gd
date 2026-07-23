class_name PlayerCursor
extends Node2D

const _pulse_particles = preload("res://Scenes/Particles/PulseParticles.tscn")

@onready var corner_box: CornerBox = %CornerBox


var pulse_time: float

var dead: bool = false

func _ready() -> void:
	corner_box.set_width(State.stats.player_size*(1+State.stats.player_size_mod))
	corner_box.position = -corner_box.size/2
	corner_box.set_color(MyColors.BLUE)

func _process(delta: float) -> void:
	if dead: return
	
	var pos: Vector2 = Globals.mouse_pos
	pos.x = clamp(pos.x, 0, Globals.SIZE.x)
	pos.y = clamp(pos.y, 0, Globals.SIZE.y)
	global_position = pos
	
	var attacks_per_sec: float = State.stats.attacks_per_sec
	attacks_per_sec *= 1+State.stats.attack_speed_mod
	pulse_time += attacks_per_sec*delta
	if pulse_time >= 1.0:
		pulse_time -= 1.0
		attack()

func attack() -> void:
	corner_box.pulse()
	SFX.play(Sound.PULSE)
	Refs.camera.shake()
	
	var results: Array[Dictionary] = ShapeCaster.box_cast(global_position, 0,
			corner_box.size, Refs.enemy_mask, [], true, false, 128)
	
	var damage: float = State.stats.damage+\
			(State.stats.max_health_damage*Refs.health.max_value)
	damage *= 1 + (results.size()*State.stats.damage_mod_per_enemy)
	
	var armor_mod: float = 1 + (results.size()*State.stats.armor_mod_per_enemy)
	if results.size() <= 8: armor_mod += State.stats.focus_armor_mod
	armor_mod += Refs.curr_scn.elapsed_time*State.stats.armor_mod_per_sec
	
	for result: Dictionary in results:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider
			
			if enemy.boss:
				damage *= 1+State.stats.boss_damage_mod
			
			enemy.take_damage(damage)
			Refs.curr_scn.enemy_hit(enemy)
			
			var total_armor: float = State.stats.armor
			total_armor += Refs.health.max_value*State.stats.max_health_armor
			total_armor *= armor_mod
			if enemy.boss:
				total_armor += State.stats.boss_armor
				total_armor *= 1+State.stats.boss_armor_mod
			
			var dmg_taken: float = max(enemy.damage-total_armor, 0)
			Refs.health.lose_health(dmg_taken)
			SFX.play(Sound.HIT, 0.2)
	
	Globals.create_pulse_bolts(global_position)

func _physics_process(delta: float) -> void:
	if dead: return
	
	var results: Array[Dictionary] = ShapeCaster.circle_cast(global_position,
			State.stats.drop_pickup_radius, Refs.enemy_drops_mask, [], true, false, 128,
			Refs.default_world)
	for result: Dictionary in results:
		Refs.drop_creator.pickup(result.rid)

