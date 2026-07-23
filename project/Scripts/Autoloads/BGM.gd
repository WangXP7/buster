extends AudioStreamPlayer

var songs: Array[AudioStreamOggVorbis] = [
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 03 Something In The Air.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 04 Small Towns, Smaller Lives.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 05 Mundane.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 06 Glad To Be Stuck Inside.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 07 Vintage.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 14 Yesterday.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 16 Cellar Door.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 17 Laundry Day.ogg"),
	preload("res://Audio/BGM/HoliznaCC0 - Lofi And Chill - 24 Static.ogg"),
]

var curr_song: AudioStreamOggVorbis
var curr_tracklist: Array[AudioStreamOggVorbis] = []

@onready var bgm_bus: int = AudioServer.get_bus_index("BGM")

@onready var low_pass: AudioEffectLowPassFilter=AudioServer.get_bus_effect(bgm_bus, 0)

func _ready() -> void:
	finished.connect(_on_finished)
	bus = "BGM"
	play_song()
	
	_set_volume(0.0)
	change_settings(1.0, 1000, 0.1)

func pull_song() -> AudioStreamOggVorbis:
	if curr_tracklist.is_empty():
		curr_tracklist = songs.duplicate()
		while curr_tracklist[0] == curr_song:
			curr_tracklist.shuffle()
	var song: AudioStreamOggVorbis = curr_tracklist.pop_front()
	return song

func play_song() -> void:
	var song = pull_song()
	curr_song = song
	stream = song
	play()

func _on_finished() -> void:
	play_song()

var settings_t: Tween
# Smoothly tweens bgm settings. Both params should be in range of [0.0, 1.0]
func change_settings(volume: float, low_pass_cutoff: float = 20500, duration: float = 0.2) -> void:
	if settings_t: settings_t.kill()
	settings_t = create_tween().set_parallel()
	
	settings_t.tween_method(_set_volume, db_to_linear(volume_db), volume, duration)
	settings_t.tween_property(low_pass, "cutoff_hz", low_pass_cutoff, duration)

func _set_volume(volume: float) -> void:
	volume_db = linear_to_db(volume)

