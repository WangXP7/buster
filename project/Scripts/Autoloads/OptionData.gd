extends Node

const path: String = "user://options.dat"
const version: int = 0


# Default options values
var data: Dictionary = {
	"version": version,
	"window_size": 0, # 0: fullscreen, otherwise: scale factor
	"vsync": 0,
	"screenshake": 90,
	"crt_effect": 0,
	"transition_color": 0,
	"flashing_fx": 0,
	"color_palette": 0,
	"master_volume": 50,
	"sfx_volume": 100,
	"bgm_volume": 60,
}

var master_bus_idx: int = AudioServer.get_bus_index("Master")
var sfx_bus_idx: int = AudioServer.get_bus_index("SFX")
var bgm_bus_idx: int = AudioServer.get_bus_index("BGM")

func _ready() -> void:
	# No saved options, create new save
	if not FileAccess.file_exists(path):
		save_options()
	# Saved options exists, load it
	else:
		var file = FileAccess.open(path, FileAccess.READ)
		var saved_option_data = str_to_var(file.get_as_text())
		file.close()
		if saved_option_data is Dictionary:
			data = saved_option_data
		else:
			save_options()
	
	if not data.has("transition_color"):
		data["transition_color"] = 0
	if not data.has("flashing_fx"):
		data["flashing_fx"] = 0
	if not data.has("color_palette"):
		data["color_palette"] = 0
	if not data.has("crt_effect"):
		data["crt_effect"] = 0
	
	await get_tree().process_frame
	for option_id: String in data:
		apply_option(option_id, data[option_id])

func save_options():
	var save_str: String = var_to_str(data)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(save_str)
		file.close()

func update_option(option_id: String, val) -> void:
	data[option_id] = val
	save_options()

func apply_option(option_id: String, val) -> void:
	match option_id:
		"window_size":
			if val == 0: # Fullscreen
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			else:
				var screen_size: Vector2i = DisplayServer.screen_get_size()
				var res: Vector2i = Vector2i(480,270)*val
				if res == screen_size:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				elif res.x > screen_size.x or res.y > screen_size.y:
					res = snapped(screen_size, Vector2i(480,270))
					_set_window_size(res)
				else:
					_set_window_size(res)
		"vsync":
			if val == 0:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			else:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		"screenshake":
			Globals.screenshake_intensity = val/100.0
		"crt_effect":
			if val == 0:
				Refs.crt.show()
				Refs.world_env.environment.glow_intensity = 1.8
			else:
				Refs.crt.hide()
				Refs.world_env.environment.glow_intensity = 0.9
		"transition_color":
			if val == 0:
				Refs.scene_transition.set_color(MyColors.WHITE)
			else:
				Refs.scene_transition.set_color(Color("8f8f8f"))
		"flashing_fx":
			Globals.flashing = val == 0
		"color_palette":
			Globals.color_palette = val
			if is_instance_valid(Refs.upgrade_tree):
				Refs.upgrade_tree.refresh_all_nodes()
		"master_volume":
			AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(val/100.0))
		"sfx_volume":
			AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(val/100.0))
		"bgm_volume":
			AudioServer.set_bus_volume_db(bgm_bus_idx, linear_to_db(val/100.0))

func _set_window_size(size: Vector2i) -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	if size == screen_size:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(size)
		var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect()
		get_window().position = screen_rect.position+screen_rect.size/2-size/2

func get_option(option_id: String) -> Variant:
	return data.get(option_id, 0)
