class_name StatsPage
extends Node2D

const _stat_entry = preload("res://Scenes/Shop/StatEntry.tscn")

@onready var vbox: VBoxContainer = %StatsVBox

# Key: Stat name, Value: StatEntry
var entry_dict: Dictionary = {}

func setup() -> void:
	update_stat("damage", State.stats.damage)
	update_stat("armor", State.stats.armor)
	update_stat("boss_armor", State.stats.boss_armor, State.stats.boss_armor>0)
	update_stat("boss_armor_mult", State.stats.boss_armor_mod,
			State.stats.boss_armor_mod>0, true)

func get_stat_description(stat_name: String) -> String:
	var s: String
	match stat_name:
		"damage":
			s = "damage you deal with each attack"
		"armor":
			s = "reduce damage from hitting enemies by this amount"
		"boss_armor":
			s = "reduce damage from hitting boss enemies by this amount"
		"boss_armor_mult":
			s = "armor against bosses is multiplied by this amount"
		_:
			s = ""
	return s

func update_stat(stat_name: String, stat_value, is_visible: bool = true,
as_percentage: bool = false) -> void:
	var entry: StatEntry
	if not entry_dict.has(stat_name):
		entry = _stat_entry.instantiate()
		vbox.add_child(entry)
		entry_dict[stat_name] = entry
		entry.stat_desc = get_stat_description(stat_name)
	else:
		entry = entry_dict[stat_name]
	
	if as_percentage:
		stat_value = "%.0f%%" % (stat_value*100.0)
	entry.setup(stat_name, stat_value)
	entry.visible = is_visible
