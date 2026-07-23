# Stores a mapping from layer name (String) to corresponding bit (int)
# Handles converting layer names to proper bitmasks
extends Node

var layers_dict = {}
var power_list = []

var render_layers_dict = {}

func _ready():
	for i in range(1, 33):
		layers_dict[ProjectSettings.get_setting("layer_names/2d_physics/layer_" + \
		str(i))] = i
		power_list.append(pow(2, i-1))
	for i in range(1, 21):
		render_layers_dict[ProjectSettings.get_setting("layer_names/2d_render/layer_" \
		+ str(i))] = i

# PHYSICS LAYERS
func index(layer_name: String) -> int:
	return layers_dict[layer_name]

# Return decimal representation of collision mask of given layer names
func bitmask(layer_names: Array) -> int:
	var sum: int = 0
	for layer_name in layer_names:
		sum += power_list[layers_dict[layer_name] - 1]
	return sum


# RENDER LAYERS
func index_render(layer_name: String) -> int:
	return render_layers_dict[layer_name]

func bitmask_render(layer_names: Array) -> int:
	var sum: int = 0
	for layer_name in layer_names:
		sum += power_list[render_layers_dict[layer_name] - 1]
	return sum

