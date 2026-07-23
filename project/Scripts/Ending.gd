class_name Ending
extends Node2D

@onready var loading_circle: Sprite2D = %Loading
@onready var loading_box: PanelContainer = %LoadingBox
@onready var virus_deployed_box: PanelContainer = %VirusDeployedBox

@onready var static_audio: AudioStreamPlayer = %StaticAudio
@onready var voice_loop: AudioStreamPlayer = %VoiceLoop
@onready var vcr: AudioStreamPlayer = %VCR
@onready var background_noise: AudioStreamPlayer = %BackgroundNoise

@onready var texture_rect: TextureRect = %TextureRect
@onready var credits: ColorRect = %Credits

@onready var anim_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	credits.hide()
	virus_deployed_box.hide()

func _process(delta: float) -> void:
	loading_circle.rotation_degrees -= 180*delta

func start_ending() -> void:
	Globals.lock_mouse(self)
	# Deploying virus...
	loading_box.show()
	SFX.play(Sound.DEPLOYING, 0)
	await MyTimer.wait(4.0)
	
	# Virus deployed!
	loading_box.hide()
	virus_deployed_box.show()
	SFX.play(Sound.DEPLOYED, 0)
	MySteam.set_achievement("DEPLOY_GODVIRUS")
	await MyTimer.wait(2.0)
	
	# Start quieting bgm
	Refs.glitch.show()
	Refs.glitch.material.set_shader_parameter("shake_power", 0.0)
	BGM.change_settings(0.0, 500, 10)
	await MyTimer.wait(2.0)
	
	# Glitch + static
	static_audio.volume_db = linear_to_db(0.0)
	static_audio.play()
	
	var t = create_tween().set_parallel(true)
	t.tween_method(_set_static_vol, 0.0, 1.0, 10.0)
	t.tween_property(Refs.glitch.material, "shader_parameter/shake_power", 0.8, 10.0)
	
	await t.finished
	static_audio.stop()
	voice_loop.play()
	vcr.play()
	
	var screen_image = Refs.main_scn.get_viewport().get_texture().get_image()
	var screen_texture = ImageTexture.create_from_image(screen_image)
	texture_rect.texture = screen_texture
	Refs.glitch.hide()
	
	await MyTimer.wait(5.0)
	
	voice_loop.stop()
	credits.show()
	
	await MyTimer.wait(2.0)
	
	background_noise.play()
	await MyTimer.wait(1.0)
	anim_player.play("Credits")
	await anim_player.animation_finished
	await MyTimer.wait(5.0)
	Refs.main_scn.enter_main_menu(false)
	Globals.unlock_mouse(self)

func _set_static_vol(val: float) -> void:
	static_audio.volume_db = linear_to_db(val)

