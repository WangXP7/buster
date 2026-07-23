class_name BattleScene
extends BaseScene

signal enter_shop()
signal restart_battle()

const _battle_end_screen = preload("res://Scenes/UI/BattleEndScreen.tscn")

@onready var enemy_spawner: EnemySpawner = %EnemySpawner
@onready var player_cursor: PlayerCursor = %PlayerCursor

@onready var ui: CanvasLayer = %UI
@onready var health_bar: PlayerHealthBar = %HealthBar
@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var terminate_btn: TextButton = %TerminateBtn

var boss_spawned: bool = false

var health_loss_per_sec: float

# Key: ResourceType (int), Value: Amount of that resource gained in this session
var collected_drops: Dictionary = {}

var elapsed_time: float = 0.0
var battle_over: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Globals.drop_collected.connect(_on_drop_collected)
	health_bar.health_zeroed.connect(_on_health_zeroed)
	terminate_btn.pressed.connect(_on_terminate_pressed)
	enemy_spawner.boss_defeated.connect(_on_boss_defeated)
	
	health_bar.setup_health(State.stats.get_max_health())
	health_bar.size.x = clamp(76+((State.stats.get_max_health()-10)/8000.0)*124, 76, 200)
	progress_bar.value = 0
	if State.curr_prestige < State.max_prestige:
		progress_bar.hide()
		boss_spawned = true
	
	if State.max_prestige > 0: %PrestigeLabel.text = "prestige %d" % State.curr_prestige
	else: %PrestigeLabel.hide()
	
	setup_pulsers.call_deferred()
	
	setup_prestige()

func setup_pulsers() -> void:
	for i: int in State.stats.auto_pulser_count:
		var pulser: MovingPulser=preload("res://Scenes/Battle/MovingPulser.tscn").instantiate()
		Refs.curr_scn.add_child(pulser)
		pulser.global_position = Vector2(randf_range(20, Globals.SIZE.x-20),
				randf_range(20, Globals.SIZE.y-20))

func setup_prestige() -> void:
	var s: EnemySpawner = enemy_spawner
	if State.curr_prestige == 0:
		s.set_spawn_rates({
			"Square": 1
		})
		s.enemy_base_health = 3.0
		s.enemy_health_growth_per_sec = 0.15
		s.enemy_base_damage = 0.4
		s.enemy_damage_growth_per_sec = 0.015
		s.boss_health = 120
		s.boss_damage = 5
		s.enemy_xp = 1
		s.bit_boost = 0
		health_loss_per_sec = 0.2
		s.enemy_speed_mod = 1.0
	elif State.curr_prestige == 1:
		s.set_spawn_rates({
			"Square": 0.86,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
		})
		s.enemy_base_health = 10.0
		s.enemy_health_growth_per_sec = 0.5
		s.enemy_base_damage = 1.0
		s.enemy_damage_growth_per_sec = 0.04
		s.boss_health = 800
		s.boss_damage = 10
		s.enemy_xp = 2
		s.bit_boost = 1
		health_loss_per_sec = 0.6
		s.enemy_speed_mod = 1.0
	elif State.curr_prestige == 2:
		s.set_spawn_rates({
			"Square": 0.86,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
		})
		s.enemy_base_health = 35.0
		s.enemy_health_growth_per_sec = 1.5
		s.enemy_base_damage = 2.5
		s.enemy_damage_growth_per_sec = 0.1
		s.boss_health = 2000
		s.boss_damage = 25
		s.enemy_xp = 3
		s.bit_boost = 3
		health_loss_per_sec = 1.2
		s.enemy_speed_mod = 1.1
	elif State.curr_prestige == 3:
		s.set_spawn_rates({
			"Square": 0.86,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
		})
		s.enemy_base_health = 100
		s.enemy_health_growth_per_sec = 4
		s.enemy_base_damage = 8
		s.enemy_damage_growth_per_sec = 0.3
		s.boss_health = 8000
		s.boss_damage = 75
		s.enemy_xp = 5
		s.bit_boost = 5
		health_loss_per_sec = 3.6
		s.enemy_speed_mod = 1.2
	elif State.curr_prestige == 4:
		s.set_spawn_rates({
			"Square": 0.78,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
		})
		s.enemy_base_health = 300
		s.enemy_health_growth_per_sec = 12
		s.enemy_base_damage = 20
		s.enemy_damage_growth_per_sec = 1.0
		s.boss_health = 24000
		s.boss_damage = 240
		s.enemy_xp = 7
		s.bit_boost = 8
		health_loss_per_sec = 10.0
		s.enemy_speed_mod = 1.3
	elif State.curr_prestige == 5:
		s.set_spawn_rates({
			"Square": 0.73,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05
		})
		s.enemy_base_health = 800
		s.enemy_health_growth_per_sec = 36
		s.enemy_base_damage = 65
		s.enemy_damage_growth_per_sec = 3.0
		s.boss_health = 70000
		s.boss_damage = 630
		s.enemy_xp = 9
		s.bit_boost = 13
		s.node_boost = 1
		health_loss_per_sec = 30.0
		s.enemy_speed_mod = 1.5
	elif State.curr_prestige == 6:
		s.set_spawn_rates({
			"Square": 0.73,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05
		})
		s.enemy_base_health = 2400
		s.enemy_health_growth_per_sec = 108
		s.enemy_base_damage = 200
		s.enemy_damage_growth_per_sec = 9.0
		s.boss_health = 210000
		s.boss_damage = 1500
		s.enemy_xp = 11
		s.bit_boost = 18
		s.node_boost = 2
		health_loss_per_sec = 90.0
		s.enemy_speed_mod = 1.65
	elif State.curr_prestige == 7:
		s.set_spawn_rates({
			"Square": 0.73,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05
		})
		s.enemy_base_health = 7200
		s.enemy_health_growth_per_sec = 300
		s.enemy_base_damage = 600
		s.enemy_damage_growth_per_sec = 26.0
		s.boss_health = 600000
		s.boss_damage = 4500
		s.enemy_xp = 13
		s.bit_boost = 18
		s.node_boost = 3
		s.bit_value = 1.4
		health_loss_per_sec = 270.0
		s.enemy_speed_mod = 1.8
	elif State.curr_prestige == 8:
		s.set_spawn_rates({
			"Square": 0.73,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05,
		})
		s.enemy_base_health = 21000
		s.enemy_health_growth_per_sec = 900
		s.enemy_base_damage = 1800
		s.enemy_damage_growth_per_sec = 78.0
		s.boss_health = 1800000
		s.boss_damage = 13500
		s.enemy_xp = 15
		s.bit_boost = 18
		s.node_boost = 4
		s.bit_value = 2.0
		health_loss_per_sec = 810.0
		s.enemy_speed_mod = 2.0
	elif State.curr_prestige == 9:
		s.set_spawn_rates({
			"Square": 0.71,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05,
			"Spiky": 0.02
		})
		s.enemy_base_health = 60000
		s.enemy_health_growth_per_sec = 2700
		s.enemy_base_damage = 5300
		s.enemy_damage_growth_per_sec = 230
		s.boss_health = 5400000
		s.boss_damage = 40000
		s.enemy_xp = 18
		s.bit_boost = 18
		s.node_boost = 5
		s.bit_value = 3.0
		health_loss_per_sec = 2400.0
		s.enemy_speed_mod = 2.0
	elif State.curr_prestige == 10:
		s.set_spawn_rates({
			"Square": 0.71,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05,
			"Spiky": 0.02
		})
		s.enemy_base_health = 180000
		s.enemy_health_growth_per_sec = 8100
		s.enemy_base_damage = 15600
		s.enemy_damage_growth_per_sec = 690
		s.boss_health = 16200000
		s.boss_damage = 120000
		s.enemy_xp = 21
		s.bit_boost = 18
		s.node_boost = 7
		s.bit_value = 4.0
		health_loss_per_sec = 7200.0
		s.enemy_speed_mod = 2.1
	elif State.curr_prestige == 11:
		s.set_spawn_rates({
			"Square": 0.71,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05,
			"Spiky": 0.02
		})
		s.enemy_base_health = 540000
		s.enemy_health_growth_per_sec = 24000
		s.enemy_base_damage = 45000
		s.enemy_damage_growth_per_sec = 2100
		s.boss_health = 48600000
		s.boss_damage = 360000
		s.enemy_xp = 24
		s.bit_boost = 18
		s.node_boost = 7
		s.bit_value = 6.0
		health_loss_per_sec = 21600.0
		s.enemy_speed_mod = 2.2
	else:
		s.set_spawn_rates({
			"Square": 0.71,
			"SmallSquare": 0.1,
			"BigSquare": 0.04,
			"Pill": 0.08,
			"Pentagon": 0.05,
			"Spiky": 0.02
		})
		s.enemy_base_health = 1500000
		s.enemy_health_growth_per_sec = 60000
		s.enemy_base_damage = 150000
		s.enemy_damage_growth_per_sec = 6000
		s.boss_health = 145000000
		s.boss_damage = 1000000
		s.enemy_xp = 27
		s.bit_boost = 18
		s.node_boost = 9
		s.bit_value = 8.0
		health_loss_per_sec = 60000.0
		s.enemy_speed_mod = 2.2
	
	if State.curr_prestige == 13:
		s.enemy_xp = 30
		s.node_boost = 11
		s.bit_value = 10.0
	elif State.curr_prestige == 14:
		s.enemy_xp = 34
		s.node_boost = 13
		s.bit_value = 12.0
	elif State.curr_prestige == 15:
		s.enemy_xp = 38
		s.node_boost = 15
		s.bit_value = 15.0
	elif State.curr_prestige == 16:
		s.enemy_xp = 42
		s.node_boost = 18
		s.bit_value = 19.0
	elif State.curr_prestige == 17:
		s.enemy_xp = 46
		s.node_boost = 18
		s.bit_value = 25.0
	elif State.curr_prestige == 18:
		s.enemy_xp = 50
		s.node_boost = 18
		s.bit_value = 32.0
	elif State.curr_prestige == 19:
		s.enemy_xp = 54
		s.node_boost = 18
		s.bit_value = 40.0
	elif State.curr_prestige == 19:
		s.enemy_xp = 58
		s.node_boost = 18
		s.bit_value = 50.0
	elif State.curr_prestige == 20:
		s.enemy_xp = 62
		s.node_boost = 18
		s.bit_value = 70.0
	elif State.curr_prestige == 21:
		s.enemy_xp = 66
		s.node_boost = 18
		s.bit_value = 110.0
	elif State.curr_prestige == 22:
		s.enemy_xp = 70
		s.node_boost = 18
		s.bit_value = 200.0
	elif State.curr_prestige == 23:
		s.enemy_xp = 74
		s.node_boost = 18
		s.bit_value = 360.0
	elif State.curr_prestige == 24:
		s.enemy_xp = 78
		s.node_boost = 18
		s.bit_value = 520.0
	elif State.curr_prestige == 25:
		s.enemy_xp = 82
		s.node_boost = 18
		s.bit_value = 720.0
	
	if State.stats.exploder_spawn_chance > 0:
		s.enemy_spawn_rates["Square"] -= State.stats.exploder_spawn_chance
		s.enemy_spawn_rates["Exploder"] = State.stats.exploder_spawn_chance

func _process(delta: float) -> void:
	if not player_cursor.dead:
		var health_change_per_sec: float = -health_loss_per_sec+\
				State.stats.health_regen+\
				(Refs.health.max_value*State.stats.max_health_regen)
		health_bar.adjust_health(health_change_per_sec*delta)
		elapsed_time += delta
	
	if not player_cursor.dead and not boss_spawned:
		progress_bar.value += delta
		if progress_bar.value >= progress_bar.max_value:
			enemy_spawner.spawn_boss()
			boss_spawned = true

func _on_drop_collected(resource_type: int, amount: int) -> void:
	if State.stats.health_on_pickup_drop > 0:
		Refs.health.adjust_health(State.stats.health_on_pickup_drop)
	
	if not collected_drops.has(resource_type):
		collected_drops[resource_type] = amount
	else:
		collected_drops[resource_type] += amount

func enemy_hit(enemy: Enemy) -> void:
	var health_gain: float = State.stats.health_on_hit
	health_gain += Refs.health.max_value*State.stats.max_health_on_hit
	Refs.health.adjust_health(health_gain)
	
	if Utils.wflip(State.stats.lightning_chance):
		var lightning_dmg: float = State.stats.damage+\
				(State.stats.max_health_damage*Refs.health.max_value)
		lightning_dmg *= 1+State.stats.lightning_damage_mod
		var lightning = Lightning.new()
		Refs.curr_scn.add_child(lightning)
		lightning.load_lightning(enemy, lightning_dmg, 80, State.stats.lightning_chains)

func _on_terminate_pressed() -> void:
	if not battle_over:
		battle_over = true
		create_battle_end_screen(2)

func _on_health_zeroed() -> void:
	if not battle_over:
		battle_over = true
		create_battle_end_screen(0)

# TODO
func _on_boss_defeated() -> void:
	if not battle_over:
		battle_over = true
		if State.max_prestige == State.curr_prestige:
			State.cores += 1
			_on_drop_collected(ResourceType.CORES, 1)
		
		create_battle_end_screen(1)
		
		if State.max_prestige == State.curr_prestige:
			if State.max_prestige < 25:
					State.max_prestige += 1
					State.curr_prestige += 1
		

func create_battle_end_screen(status: int) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_cursor.dead = true
	player_cursor.hide()
	
	var battle_end_screen: BattleEndScreen = _battle_end_screen.instantiate()
	ui.add_child(battle_end_screen)
	battle_end_screen.setup(collected_drops, status)
	battle_end_screen.home_pressed.connect(_on_battle_end_home)
	battle_end_screen.restart_pressed.connect(_on_battle_end_restart)

func _on_battle_end_home() -> void:
	enter_shop.emit()

func _on_battle_end_restart() -> void:
	restart_battle.emit()

func play_level_up_fx() -> void:
	Effects.instantiate(preload("res://Scenes/Particles/LevelUpParticles.tscn"),
			player_cursor.global_position)
	Effects.floating_text("LEVEL UP", player_cursor.global_position, MyColors.YELLOW)
	SFX.play(Sound.LEVEL_UP, 0)
