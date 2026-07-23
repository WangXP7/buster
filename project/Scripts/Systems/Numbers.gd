class_name Numbers
extends RefCounted

var enemies_killed: int = 0

var reds_killed: int = 0
var blues_killed: int = 0
var yellows_killed: int = 0


func save() -> Dictionary:
	var save: Dictionary = inst_to_dict(self)
	save.erase("@path")
	save.erase("@subpath")
	return save

func load_save(save: Dictionary) -> Numbers:
	var prop_list: Array = get_property_list()
	for property in prop_list:
		if save.has(property.name):
			set(property.name, save[property.name])
	return self
