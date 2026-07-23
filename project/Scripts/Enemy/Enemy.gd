class_name Enemy
extends Area2D

signal died()
signal out_of_bounds()

@onready var collider: CollisionShape2D = %CollisionShape2D
@onready var texture_bar: TextureProgressBar = %TextureProgressBar

var enemy_id: String

var color: Color
var rotate_speed: float
var resource_type: int

var max_health: float
var curr_health: float

var move_dir: Vector2
var movespeed: float
# Wavy movement
var wavy: bool = false
var period: float = 1.0
var amplitude: float = 34.0
var rotate_to_velocity: bool = false

var time_alive: float = 0
var dead: bool = false

var damage: float

var xp_mult: float = 1.0
var drop_mult: float = 1.0

var boss: bool = false
var rainbow: bool = false

func set_color(_color: Color) -> void:
	color = _color
	modulate = color

func setup(_resource_type: int, _max_health: float, _damage: float, _movespeed: float,
_scale: float) -> void:
	resource_type = _resource_type
	max_health = _max_health
	curr_health = max_health
	texture_bar.max_value = max_health
	damage = _damage
	movespeed = _movespeed
	scale = Vector2(_scale, _scale)
	texture_bar.pivot_offset = texture_bar.size/2
	update_bar()
	
	set_color(ResourceType.get_color(resource_type))

func set_move_dir(dir: Vector2) -> void:
	move_dir = dir

func get_width() -> float:
	return 128*scale.x

func take_damage(amount: float) -> void:
	Effects.instantiate(preload("res://Scenes/Particles/HitParticles.tscn"),
			global_position).self_modulate = color
	
	# TODO: Move these out of this function, maybe?
	var damage_mods: float = 0.0
	if curr_health >= max_health:
		damage_mods += State.stats.undamaged_mod
	elif curr_health/max_health <= 0.5:
		damage_mods += State.stats.execute_mod
	damage_mods += Refs.curr_scn.elapsed_time*State.stats.damage_mod_per_sec
	
	amount *= 1+damage_mods
	if Utils.wflip(State.stats.crit_chance):
		amount *= 1+State.stats.crit_damage
	
	curr_health -= amount
	if curr_health <= 0 and not dead:
		var width: float = get_width()
		Effects.square_impact(global_position, rotation_degrees,
				Vector2(width+6,width+6), color)
		set_dead()
		died.emit()
		queue_free()
	else:
		update_bar()
		pulse()

func pulse() -> void:
	if Globals.flashing:
		modulate = MyColors.WHITE
	Springer.scale(texture_bar, 10/get_width()).set_range(0.5, 1.5)
	await MyTimer.wait(0.1)
	modulate = color

func _process(delta: float) -> void:
	if rainbow:
		modulate.h = fmod(modulate.h+delta, 1.0)

func _physics_process(delta: float) -> void:
	time_alive += delta
	
	var curr_dir: Vector2 = move_dir
	if wavy:
		var perp: Vector2 = Utils.perp_ccw(move_dir)
		var perp_length: float = sin(time_alive * period) * amplitude
		curr_dir = (move_dir*movespeed + perp*perp_length).normalized()
	
	position += curr_dir * movespeed * delta
	
	if rotate_to_velocity:
		rotation = curr_dir.angle()
	else:
		rotation = fmod(rotation+rotate_speed*delta, TAU)
	
	# Check if out of game bounds
	var width: float = get_width()*0.7
	if time_alive >= 5.0 and (global_position.x > Globals.SIZE.x + width or \
	global_position.x < -width or \
	global_position.y > Globals.SIZE.y + width or \
	global_position.y < -width):
		out_of_bounds.emit()

func update_bar() -> void:
	texture_bar.value = curr_health

func set_dead() -> void:
	dead = true
