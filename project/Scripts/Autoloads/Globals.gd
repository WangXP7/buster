extends Node2D

# Global signals
signal drop_collected(resource_type: int, amount: int)


const SIZE: Vector2 = Vector2(480, 270)

var mouse_pos: Vector2
var screenshake_intensity: float

var color_palette: int
var flashing: bool

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()

var mouse_blocker: Control
var mouse_locks: Dictionary = {}
func lock_mouse(holder) -> void:
	mouse_locks[holder] = true
	mouse_blocker.show()
func unlock_mouse(holder) -> void:
	mouse_locks.erase(holder)
	mouse_blocker.visible = not mouse_locks.is_empty()
func is_mouse_locked() -> bool:
	return not mouse_locks.is_empty()


# If play_effects: do shake + pulse sfx
func create_explosion(pos: Vector2, dangle: float, width: float, damage_mod: float = 0.0,
play_effects: bool = true) -> void:
	Effects.corner_box(pos, dangle, width, MyColors.BLUE)
	if play_effects:
		SFX.play(Sound.PULSE)
		Refs.camera.shake()
	
	var results: Array[Dictionary] = ShapeCaster.box_cast(pos, dangle,
			Vector2(width, width), Refs.enemy_mask, [], true, false, 128)
	
	var damage: float = State.stats.damage+(State.stats.max_health_damage*Refs.health.max_value)
	damage *= 1 + (results.size()*State.stats.damage_mod_per_enemy) + damage_mod
	
	for result: Dictionary in results:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider
			
			if enemy.boss:
				damage *= 1+State.stats.boss_damage_mod
			enemy.take_damage(damage)
			Refs.curr_scn.enemy_hit(enemy)
			SFX.play(Sound.HIT, 0.2)

const _pulse_bolt = preload("res://Scenes/Player/PulseBolt.tscn")
func create_pulse_bolts(pos: Vector2) -> void:
	if State.stats.pulse_bolt_count > 0:
		var dangles: Array[float] = Utils.subdivide_angle(-90, 270, State.stats.pulse_bolt_count)
		var bolt_dmg: float = State.stats.damage+\
				(State.stats.max_health_damage*Refs.health.max_value)
		bolt_dmg *= (1+State.stats.pulse_bolt_damage_mod)
		for dangle: float in dangles:
			var bolt: PulseBolt = _pulse_bolt.instantiate()
			Refs.curr_scn.add_child(bolt)
			bolt.global_position = pos
			bolt.setup(dangle, bolt_dmg)
