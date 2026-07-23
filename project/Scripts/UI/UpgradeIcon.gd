class_name UpgradeIcon
extends NinePatchRect

@onready var texture_rect: TextureRect = %TextureRect

var upgrade: Upgrade


func load_upgrade(_upgrade: Upgrade) -> void:
	upgrade = _upgrade
	texture_rect.texture = upgrade.icon

func setup_outline_color() -> void:
	if upgrade.is_maxed():
		if Globals.color_palette == 0: self_modulate = MyColors.YELLOW
		else: self_modulate = MyColors.VIOLET
	else:
		if upgrade.can_buy():
			self_modulate = MyColors.GREEN
		else:
			if Globals.color_palette == 0: self_modulate = MyColors.RED
			else: self_modulate = MyColors.DARK_RED

func set_outline_color(color: Color) -> void:
	self_modulate = color
