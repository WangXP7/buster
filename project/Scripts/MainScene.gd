class_name MainScene
extends Node2D

const _main_menu = preload("res://GameScenes/MainMenu.tscn")
const _shop_scn = preload("res://GameScenes/ShopScene.tscn")
const _battle_scn = preload("res://GameScenes/BattleScene.tscn")

@onready var root: Node2D = %Root
@onready var viewport_container: SubViewportContainer = %GameViewportContainer
@onready var viewport: SubViewport = %GameViewport
@onready var game_canvas: CanvasLayer = %GameCanvas

var curr_scn: BaseScene

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	ShapeCaster.world = viewport.world_2d
	Refs.main_scn = self
	Refs.default_world = get_world_2d()
	Refs.viewport = viewport
	Refs.physics_state = viewport.world_2d.space
	Refs.root = root
	Refs.popups = %PopupManager
	Refs.tooltip = %Tooltip
	Refs.upgrade_processor = %UpgradeProcessor
	Refs.world_env = %WorldEnvironment
	Refs.crt = %CRT
	Refs.glitch = %Glitch
	Globals.mouse_blocker = %MouseBlocker
	
	Saver.load_game()
	enter_main_menu.call_deferred(false)

func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey and event.keycode == KEY_SHIFT:
			if event.pressed:
				Engine.time_scale = 6
			else:
				Engine.time_scale = 1
		if event is InputEventKey and event.keycode == KEY_L:
			if event.pressed:
				await Refs.scene_transition.transition_in("INITIALIZING SESSION...")
				await Refs.scene_transition.transition_out()
	#if event.is_action_pressed("lmb"):
		#Effects.floating_text("LEVEL UP", Globals.mouse_pos, MyColors.YELLOW)

func enter_main_menu(transition: bool = true) -> void:
	if transition: await Refs.scene_transition.transition_in("RETURNING TO MENU...")
	
	if curr_scn: curr_scn.queue_free()
	await get_tree().process_frame
	curr_scn = _main_menu.instantiate()
	root.add_child(curr_scn)
	Refs.curr_scn = curr_scn
	
	curr_scn.new_game.connect(_on_new_game)
	curr_scn.continue_game.connect(_on_continue_game)
	
	BGM.change_settings(1.0, 1000, 0.5)
	if transition: await Refs.scene_transition.transition_out()
	curr_scn.setup()

func _on_new_game() -> void:
	var start_game: bool = true
	if Saver.has_save():
		var confirmation: ConfirmationPopup = Refs._confirmation.instantiate()
		Refs.popups.add_popup(confirmation)
		await Defer.new_frame
		confirmation.setup("Start a new save? Your old save will be permanently deleted.", "no", "yes")
		Refs.popups.focus_curr()
		start_game = await confirmation.chosen
		if start_game:
			Saver.create_new_save()
		Refs.popups.pop_curr()
	if start_game:
		Saver.save_game()
		enter_shop()

func _on_continue_game() -> void:
	if Saver.has_save():
		Saver.load_game()
		enter_shop()

func enter_shop() -> void:
	Saver.save_game()
	await Refs.scene_transition.transition_in("ENTERING HOME...")
	
	if curr_scn: curr_scn.queue_free()
	await get_tree().process_frame
	curr_scn = _shop_scn.instantiate()
	root.add_child(curr_scn)
	Refs.curr_scn = curr_scn
	
	curr_scn.enter_battle.connect(_on_shop_enter_battle)
	
	BGM.change_settings(0.8, 800, 0.5)
	await Refs.scene_transition.transition_out()
	curr_scn.setup()

func _on_shop_enter_battle() -> void:
	enter_battle()

func enter_battle() -> void:
	Saver.save_game()
	await Refs.scene_transition.transition_in("INITIALIZING SESSION...")
	
	if curr_scn: curr_scn.queue_free()
	await get_tree().process_frame
	curr_scn = _battle_scn.instantiate()
	root.add_child(curr_scn)
	Refs.curr_scn = curr_scn
	
	curr_scn.enter_shop.connect(_on_battle_enter_shop)
	curr_scn.restart_battle.connect(_on_restart_battle)
	
	BGM.change_settings(1.0, 5000, 0.5)
	await Refs.scene_transition.transition_out()
	curr_scn.setup()
	
	State.sessions += 1
	MySteam.set_achievement("FIRST_SESSION", false)
	if State.sessions >= 50: MySteam.set_achievement("TOTAL_SESSIONS_50", false)
	Steam.storeStats()

func _on_battle_enter_shop() -> void:
	enter_shop()
func _on_restart_battle() -> void:
	enter_battle()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		try_save()

func try_save() -> void:
	if Saver.has_save():
		Saver.save_game()
