class_name ResourceType

enum {
	BITS,
	NODES,
	CORES,
	SP,
	NETCOIN,
	PROCESSORS,
}

const NAMES = {
	BITS: "Bits",
	NODES: "Nodes",
	CORES: "Cores",
	SP: "SP",
	NETCOIN: "Netcoin",
	PROCESSORS: "Processors",
}

const ICONS = {
	BITS: preload("res://Sprites/UI/Red.png"),
	NODES: preload("res://Sprites/UI/Blue.png"),
	CORES: preload("res://Sprites/UI/Purple.png"),
	SP: preload("res://Sprites/UI/SP.png"),
	NETCOIN: preload("res://Sprites/UI/Netcoin.png"),
	PROCESSORS: preload("res://Sprites/UI/Processors.png"),
}

static func get_icon(resource_type: int) -> Texture2D:
	return ICONS[resource_type]

static func get_color(resource_type: int) -> Color:
	if resource_type == BITS: return MyColors.RED
	elif resource_type == NODES: return MyColors.DARK_BLUE
	elif resource_type == CORES: return MyColors.PURPLE
	elif resource_type == SP: return MyColors.BLUE
	elif resource_type == NETCOIN: return MyColors.GREEN
	elif resource_type == PROCESSORS: return MyColors.YELLOW
	else: return MyColors.WHITE

# Given a ResourceType (enum), return the bbcode for its img tag
static func get_icon_bbcode(resource_type: int) -> String:
	var path: String = get_icon(resource_type).resource_path
	return "[img]%s[/img]" % path

# Given a ResourceType (enum), return bbcode for the icon + the given string in the right color
static func resource_str(resource_type: int, string: String) -> String:
	# NOTE: There are invisible word joiner characters here
	var res: String = "%s⁠ ⁠%s%s[/color]" % \
				[get_icon_bbcode(resource_type), Utils.hex(get_color(resource_type)),
				string]
	return res

static func resource_name(resource_type: int) -> String:
	var name: String = NAMES[resource_type]
	return resource_str(resource_type, name)
