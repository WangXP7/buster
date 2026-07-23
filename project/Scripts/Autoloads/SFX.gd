extends Node

var sound_dict: Dictionary = {
	Sound.BUTTON_HOVER: preload("res://Audio/SFX/ButtonHover5.ogg"),
	Sound.BUTTON_DOWN: preload("res://Audio/SFX/ButtonDown2.ogg"),
	Sound.BUTTON_UP: preload("res://Audio/SFX/ButtonUp4.ogg"),
	Sound.BUTTON_CLICK: preload("res://Audio/SFX/ButtonOneClick.ogg"),
	Sound.PICKUP_START: preload("res://Audio/SFX/PickupStart.ogg"),
	Sound.PICKUP_RESOURCE: preload("res://Audio/SFX/Pickup2.ogg"),
	Sound.PULSE: preload("res://Audio/SFX/Pulse.ogg"),
	Sound.HIT: preload("res://Audio/SFX/Hit2.ogg"),
	Sound.TICK: preload("res://Audio/SFX/Tick3.ogg"),
	Sound.LEVEL_UP: preload("res://Audio/SFX/LevelUpJingle.ogg"),
	Sound.LOSE: preload("res://Audio/SFX/Lose.ogg"),
	Sound.WIN: preload("res://Audio/SFX/Win.ogg"),
	Sound.MOUSE_DOWN: preload("res://Audio/SFX/MouseDown.ogg"),
	Sound.MOUSE_UP: preload("res://Audio/SFX/MouseUp.ogg"),
	Sound.TYPE: [
		preload("res://Audio/SFX/Type1.ogg"),
		preload("res://Audio/SFX/Type2.ogg"),
		preload("res://Audio/SFX/Type3.ogg"),
		preload("res://Audio/SFX/Type4.ogg"),
		preload("res://Audio/SFX/Type5.ogg"),
	],
	Sound.TRANSITION_IN: preload("res://Audio/SFX/TransitionIn3.ogg"),
	Sound.TRANSITION_OUT: preload("res://Audio/SFX/TransitionOut.ogg"),
	Sound.PLINK: preload("res://Audio/SFX/Plink3.ogg"),
	Sound.ELECTRICITY: preload("res://Audio/SFX/Electricity.ogg"),
	Sound.DEPLOYING: preload("res://Audio/SFX/Deploying.ogg"),
	Sound.DEPLOYED: preload("res://Audio/SFX/Deployed.ogg"),
}

var cooldown_dict: Dictionary = {}

# Audio players for short sfx
var players_short: Array = []
var short_index: int = 0

var base_volume: float

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i in range(50):
		var audio_player = AudioStreamPlayer.new()
		audio_player.volume_db = base_volume
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		audio_player.bus = "SFX"
		get_tree().root.call_deferred("add_child", audio_player)
		players_short.append(audio_player)
	for key in sound_dict:
		cooldown_dict[key] = 0

func _physics_process(delta):
	for key in cooldown_dict:
		if cooldown_dict[key] > 0:
			cooldown_dict[key] -= 1

func play(sound: int, rand_pitch_range: float = 0.05, volume_delta: float = 0.0,
pitch_offset: float = 0.0, cooldown_frames: int = 1) -> void:
	assert(rand_pitch_range >= 0)
	if cooldown_dict[sound] > 0:
		return
	
	var stream = sound_dict[sound]
	if stream is Array:
		stream = stream.pick_random()
	
	var source = players_short[short_index] as AudioStreamPlayer
	source.playing = false
	source.stream = stream
	source.pitch_scale = 1.0+pitch_offset+\
			randf_range(-rand_pitch_range, rand_pitch_range)
	
	source.volume_db = base_volume + volume_delta
	source.play(0.0)
	
	cooldown_dict[sound] = cooldown_frames
	
	short_index = (short_index + 1) % players_short.size()


func create_source(parent: Node2D, sound: int, rand_pitch_range: float = 0.08,
volume_delta: float = 0.0) -> AudioStreamPlayer:
	var source = AudioStreamPlayer.new()
	parent.add_child(source)
	source.playing = false
	source.stream = sound_dict[sound]
	source.pitch_scale = randf_range(1.0 - rand_pitch_range, 1.0 + rand_pitch_range)
	source.volume_db = base_volume + volume_delta
	source.bus = "SFX"
	
	return source

