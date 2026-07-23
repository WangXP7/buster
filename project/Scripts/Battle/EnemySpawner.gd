class_name EnemySpawner
extends Node2D

signal boss_defeated()

# Enemy scenes
var _square = preload("res://Scenes/Enemies/EnemySquare.tscn")
var _pill = preload("res://Scenes/Enemies/EnemyPill.tscn")
var _circle = preload("res://Scenes/Enemies/EnemyCircle.tscn")
var _spiky = preload("res://Scenes/Enemies/EnemySpikyBall.tscn")
var _pentagon = preload("res://Scenes/Enemies/EnemyPentagon.tscn")


var sides: Array[int] = [0,1,2,3]

var curr_spawn_delta: float = 2


var enemy_spawn_rates: Dictionary = {}
var yellow_spawn_rates: Dictionary = {}

var enemy_base_health: float
var enemy_health_growth_per_sec: float

var enemy_base_damage: float
var enemy_damage_growth_per_sec: float

var boss_health: float
var boss_damage: float

var enemy_speed_mod: float = 1.0

var enemy_xp: int
var bit_boost: int
var node_boost: int

# If not an int, then the decimal is used as a % chance to gain extra
var bit_value: float = 1.0


func _ready() -> void:
	Refs.drop_creator.picked_up.connect(_on_pickup_drop)

func set_spawn_rates(spawn_rates: Dictionary) -> void:
	enemy_spawn_rates = spawn_rates
	yellow_spawn_rates = enemy_spawn_rates.duplicate()
	yellow_spawn_rates.erase("BigSquare")
	yellow_spawn_rates.erase("Pentagon")

var t: float
func _process(delta: float) -> void:
	curr_spawn_delta += State.stats.spawn_rate * State.stats.spawn_rate_mod * delta
	while curr_spawn_delta >= 1.0:
		curr_spawn_delta -= 1.0
		var enemy_resource_type: int = ResourceType.BITS
		if Utils.wflip(State.stats.yellow_enemy_chance):
			enemy_resource_type = ResourceType.PROCESSORS
		elif Utils.wflip(State.stats.blue_enemy_chance):
			enemy_resource_type = ResourceType.NODES
		
		var enemy_type: String
		if enemy_resource_type == ResourceType.PROCESSORS:
			enemy_type = Utils.pull_weighted(yellow_spawn_rates)
		else:
			enemy_type = Utils.pull_weighted(enemy_spawn_rates)
		
		spawn_enemy(enemy_resource_type, enemy_type)
	
	t += delta
	enemy_base_health += enemy_health_growth_per_sec * delta
	enemy_base_damage += enemy_damage_growth_per_sec * delta

func spawn_enemy(enemy_resource_type: int, enemy_type: String) -> Enemy:
	var enemy_scn: PackedScene
	
	var move_speed: float
	var rotate_speed: float
	var scale_val: float
	var health_mult: float = 1.0
	var drop_mult: float = 1.0
	var xp_mult: float = 1.0
	var damage_mult: float = 1.0
	var wavy: bool = false
	var rotate_to_velocity: bool = false
	
	if enemy_type == "Square":
		enemy_scn = _square
		rotate_speed = TAU * randf_range(0.12, 0.25) * Utils.flipi()
		scale_val = randf_range(0.14, 0.18)
		move_speed = randf_range(18, 22)
	elif enemy_type == "SmallSquare":
		enemy_scn = _square
		rotate_speed = TAU * randf_range(0.16, 0.26) * Utils.flipi()
		scale_val = randf_range(0.08, 0.1)
		move_speed = randf_range(30, 36)
		health_mult = 0.6
	elif enemy_type == "BigSquare":
		enemy_scn = _square
		scale_val = randf_range(0.45, 0.5)
		move_speed = randf_range(12, 15)
		health_mult = 5.0
		drop_mult = 3.0
		xp_mult = 4.0
	elif enemy_type == "Exploder":
		enemy_scn = _circle
		rotate_speed = TAU * randf_range(0.12, 0.25) * Utils.flipi()
		scale_val = randf_range(0.14, 0.18)
		move_speed = randf_range(18, 22)
	elif enemy_type == "Pill":
		enemy_scn = _pill
		rotate_speed = 0
		scale_val = randf_range(0.16, 0.22)
		move_speed = randf_range(20, 24)
		wavy = true
		rotate_to_velocity = true
	elif enemy_type == "Pentagon":
		enemy_scn = _pentagon
		rotate_speed = TAU*randf_range(0.15, 0.2) * Utils.flipi()
		scale_val = randf_range(0.4, 0.45)
		move_speed = randf_range(14, 18)
		health_mult = 3.0
		drop_mult = 2.0
		xp_mult = 2.0
	elif enemy_type == "PentagonSmall":
		enemy_scn = _pentagon
		rotate_speed = TAU*randf_range(0.2, 0.26) * Utils.flipi()
		scale_val = randf_range(0.1, 0.12)
		move_speed = randf_range(26, 32)
		health_mult = 0.6
	elif enemy_type == "Spiky":
		enemy_scn = _spiky
		rotate_speed = TAU*randf_range(0.16, 0.2) * Utils.flipi()
		scale_val = randf_range(0.3, 0.34)
		move_speed = randf_range(14, 18)
		health_mult = 2.0
		drop_mult = 4.0
		xp_mult = 2.0
		damage_mult = 3.0
	
	var enemy: Enemy = _create_enemy(enemy_scn, enemy_resource_type,
			enemy_base_health*health_mult, enemy_base_damage*damage_mult,
			move_speed*enemy_speed_mod, rotate_speed, scale_val)
	enemy.enemy_id = enemy_type
	enemy.drop_mult = drop_mult
	enemy.xp_mult = xp_mult
	enemy.wavy = wavy
	enemy.rotate_to_velocity = rotate_to_velocity
	
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.out_of_bounds.connect(_on_enemy_out_of_bounds.bind(enemy))
	return enemy

func spawn_boss() -> void:
	var rotate_speed: float = TAU * 0.1 * Utils.flipi()
	var enemy: Enemy = _create_enemy(_square, ResourceType.CORES, boss_health, boss_damage,
			15, rotate_speed, 1.0)
	enemy.boss = true
	if State.curr_prestige >= 18:
		enemy.rainbow = true
	
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.out_of_bounds.connect(_on_boss_out_of_bounds.bind(enemy))


func _create_enemy(enemy_scn: PackedScene, resource_type: int, health: float,
damage: float, move_speed: float, rotate_speed: float, scale_val: float) -> Enemy:
	var enemy: Enemy = enemy_scn.instantiate()
	add_child(enemy)
	
	enemy.rotate_speed = rotate_speed
	enemy.setup(resource_type, health, damage, move_speed, scale_val)
	randomly_place_enemy(enemy)
	
	return enemy

# Given an enemy, place it in a random spawn position and give it a proper direction
func randomly_place_enemy(enemy: Enemy) -> void:
	enemy.global_position = get_random_spawn_pos(enemy.get_width()*0.7)
	var passthru_point: Vector2 = Refs.camera.global_position+Utils.rand_in_radius(84)
	var dir: Vector2 = enemy.global_position.direction_to(passthru_point)
	enemy.set_move_dir(dir)

func get_random_spawn_pos(offset: float) -> Vector2:
	var side: int = sides.pick_random()
	var x: float
	var y: float
	var origin: Vector2 = Refs.camera.global_position
	
	var top_left: Vector2 = Vector2(origin.x-Globals.SIZE.x/2-offset,
			origin.y-Globals.SIZE.y/2-offset)
	var bot_right: Vector2 = Vector2(origin.x+Globals.SIZE.x/2+offset,
			origin.y+Globals.SIZE.y/2+offset)
	
	# Top (0) or Bot (2)
	if side == 0 or side == 2:
		if side == 0: y = top_left.y
		else: y = bot_right.y
		x = randf_range(top_left.x, bot_right.x)
	# Right (1) or Left (3)
	else:
		if side == 1: x = bot_right.x
		else: x = top_left.x
		y = randf_range(top_left.y, bot_right.y)
	
	return Vector2(x,y)

func get_random_enemy() -> Enemy:
	return get_child(randi_range(0, get_child_count()-1))

func _on_enemy_out_of_bounds(enemy: Enemy) -> void:
	enemy.queue_free()

func _on_boss_out_of_bounds(boss: Enemy) -> void:
	randomly_place_enemy(boss)

func _on_enemy_died(enemy: Enemy) -> void:
	enemy.set_dead()
	
	Refs.health.gain_max_health(State.stats.perma_max_health_on_kill)
	State.bonus_max_health += State.stats.perma_max_health_on_kill
	
	Refs.health.adjust_health(State.stats.health_on_kill)
	if enemy.boss:
		boss_defeated.emit()
	else:
		var drop_count: int = 1
		if enemy.resource_type != ResourceType.PROCESSORS:
			if enemy.resource_type == ResourceType.BITS:
				drop_count += State.stats.bit_boost + bit_boost
				State.nums.reds_killed += 1
			elif enemy.resource_type == ResourceType.NODES:
				drop_count += State.stats.node_boost + node_boost
				State.nums.blues_killed += 1
			drop_count *= enemy.drop_mult
			if Utils.wflip(State.stats.bonus_drop_chance):
				drop_count *= 2
		else:
			State.nums.yellows_killed += 1
		
		_create_drops.call_deferred(drop_count, enemy.resource_type, enemy.global_position,
				enemy.get_width()*0.5)
	
	if enemy.enemy_id == "Exploder":
		var explosion_size: float = 110 * (1+State.stats.exploder_size)
		Globals.create_explosion(enemy.global_position, randf_range(0,90), explosion_size)
	elif enemy.enemy_id == "Pentagon":
		for i: int in 6:
			_create_pentagon_children.call_deferred(enemy.resource_type,
					enemy.global_position, enemy.move_dir)
	if Utils.wflip(State.stats.enemy_death_pulse_bolt_chance):
		Globals.create_pulse_bolts.call_deferred(enemy.global_position)
	
	State.nums.enemies_killed += 1
	Refs.xp.gain_xp(enemy_xp * enemy.xp_mult)

func _create_drops(drop_count: int, resource_type: int, base_pos: Vector2,
scatter_radius: float) -> void:
	for i: int in drop_count:
		if Utils.wflip(State.stats.autocollect_chance):
			_on_pickup_drop(resource_type)
		else:
			var drop_pos: Vector2 = base_pos + Utils.rand_in_radius(scatter_radius)
			Refs.drop_creator.create_drop(drop_pos, resource_type)

func _create_pentagon_children(resource_type: int, base_pos: Vector2, move_dir: Vector2)\
 -> void:
	var child: Enemy = spawn_enemy(resource_type, "PentagonSmall")
	child.global_position = base_pos + Utils.rand_in_radius(40)
	child.set_move_dir(move_dir)

func _on_pickup_drop(resource_type: int) -> void:
	var amount: int = 1
	if resource_type == ResourceType.BITS:
		amount = int(bit_value)
		if Utils.wflip(bit_value-amount):
			amount += 1
		
	State.gain_resource(resource_type, amount)
	Globals.drop_collected.emit(resource_type, amount)
