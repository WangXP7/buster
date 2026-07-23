class_name Milestone
extends RefCounted

var id: StringName
var icon: Texture2D
var name: String
var unlock_desc: String
var reward: String

var claimed: bool = false

func _init(data: Dictionary = {}) -> void:
	if data.is_empty(): return
	
	id = data.id
	icon = load("res://Sprites/MilestoneIcons/%s.png" % id)
	name = data.name
	unlock_desc = data.unlock_desc
	reward = data.reward

