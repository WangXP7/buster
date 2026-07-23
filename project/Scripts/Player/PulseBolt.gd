class_name PulseBolt
extends Area2D

@onready var shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D

var damage: float
var dir: Vector2
var speed: float = 300
var lifetime: float = randf_range(0.4, 0.6)

var time_alive: float = 0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func setup(dangle: float, _damage: float) -> void:
	rotation_degrees = dangle
	damage = _damage
	dir = Utils.dir_from_rangle(deg_to_rad(dangle))

func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	time_alive += delta
	
	if time_alive >= lifetime:
		if State.stats.pulse_bolt_explode:
			Globals.create_explosion(global_position, randf_range(0, 90), 64,
					State.stats.pulse_bolt_damage_mod, false)
			SFX.play(Sound.PULSE)
		Effects.square_impact(global_position, 0, Vector2(16, 16), MyColors.BLUE)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		area.take_damage(damage)
		Effects.square_impact(global_position, 0, Vector2(16, 16), MyColors.BLUE)
		SFX.play(Sound.HIT, 0.2)
		Refs.curr_scn.enemy_hit(area)
