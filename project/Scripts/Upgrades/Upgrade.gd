class_name Upgrade
extends RefCounted

var id: StringName
var icon: Texture2D
var name: String
var description: String
var resource_type: int
var costs: Array

var curr_level: int


func _init(data: Dictionary = {}) -> void:
	if data.is_empty(): return
	
	id = data.id
	icon = load("res://Sprites/UpgradeIcons/%s.png" % id)
	name = data.name
	description = data.description
	resource_type = data.resource_type
	costs.assign(data.costs)

func get_max_level() -> int:
	return costs.size()

func is_maxed() -> bool:
	return curr_level >= costs.size()

# Returns -1 if curr_level isn't in costs
func get_cost():
	if curr_level < 0 or curr_level >= costs.size(): return -1
	return costs[curr_level]

func can_buy() -> bool:
	return State.has_resource(resource_type, get_cost()) and not is_maxed()

