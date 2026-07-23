class_name Stats
extends RefCounted

# Contains data that shouldn't be saved to disk
var milestones_unlocked: bool = false
var crypto_mine_unlocked: bool = false
var lab_unlocked: bool = false

var damage: int = 1
var undamaged_mod: float = 0.0
var execute_mod: float = 0.0
var damage_mod_per_enemy: float = 0
var boss_damage_mod: float = 0.0
var damage_mod_per_sec: float = 0.0
var max_health_damage: float = 0.0

var crit_chance: float = 0.0
var crit_damage: float = 1.0

var attacks_per_sec: float = 0.5
var attack_speed_mod: float = 0.0

var max_health: int = 10
var health_regen: float = 0.0
var max_health_regen: float = 0.0
var health_on_kill: float = 0
var health_on_hit: float = 0
var max_health_on_hit: float = 0
var health_on_pickup_drop: float = 0
var perma_max_health_on_kill: int = 0

func get_max_health() -> int:
	return max_health + State.bonus_max_health

var armor: float = 0
var boss_armor: float = 0
var boss_armor_mod: float = 0
var armor_mod_per_enemy: float = 0
var focus_armor_mod: float = 0.0
var max_health_armor: float = 0.0
var armor_mod_per_sec: float = 0.0

var drop_pickup_radius: float = 16

var player_size: float = 34
var player_size_mod: float = 0.0

# Enemies per second
var spawn_rate: float = 0.33
var spawn_rate_mod: float = 1.0

var bit_boost: int = 0
var node_boost: int = 0
var bonus_drop_chance: float = 0.0
var autocollect_chance: float = 0.0

var exploder_spawn_chance: float = 0.0
var exploder_size: float = 0.0
var blue_enemy_chance: float = 0.0
var yellow_enemy_chance: float = 0.0

# Pulse bolts
var pulse_bolt_count: int = 0
var pulse_bolt_damage_mod: float = 0.0
var pulse_bolt_explode: bool = false
var enemy_death_pulse_bolt_chance: float = 0.0

# Auto pulsers
var auto_pulser_count: int = 0
var auto_pulser_attack_speed_mod: float = 0.0
var auto_pulser_size_mod: float = 0.0
var auto_pulser_speed_mod: float = 0.0

# Lightning
var lightning_chance: float = 0.0
var lightning_damage_mod: float = 0.0
var lightning_chains: int = 2
