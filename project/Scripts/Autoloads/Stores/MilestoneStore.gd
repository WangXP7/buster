extends Node

var data: Array[Milestone] = [
	Milestone.new({
		"id": "Reds500",
		"name": "RED DEFEATER",
		"unlock_desc": "destroy 500 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "500"),
	}),
	Milestone.new({
		"id": "Blues10",
		"name": "BLUE DEFEATER",
		"unlock_desc": "destroy 10 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "5"),
	}),
	Milestone.new({
		"id": "Reds2k",
		"name": "RED ENEMY",
		"unlock_desc": "destroy 2,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "3,000"),
	}),
	Milestone.new({
		"id": "Blues100",
		"name": "BLUE ENEMY",
		"unlock_desc": "destroy 100 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "100"),
	}),
	Milestone.new({
		"id": "Reds4k",
		"name": "RED SLAYER",
		"unlock_desc": "destroy 4,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "5,000"),
	}),
	Milestone.new({
		"id": "Blues200",
		"name": "BLUE SLAYER",
		"unlock_desc": "destroy 200 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "200"),
	}),
	Milestone.new({
		"id": "Reds6k",
		"name": "RED BUSTER",
		"unlock_desc": "destroy 6,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "8,000"),
	}),
	Milestone.new({
		"id": "Blues300",
		"name": "BLUE BUSTER",
		"unlock_desc": "destroy 300 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "300"),
	}),
	Milestone.new({
		"id": "Reds8k",
		"name": "RED HACKER",
		"unlock_desc": "destroy 8,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "12,000"),
	}),
	Milestone.new({
		"id": "Blues500",
		"name": "BLUE HACKER",
		"unlock_desc": "destroy 500 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "500"),
	}),
	Milestone.new({
		"id": "Reds10k",
		"name": "RED DESTROYER",
		"unlock_desc": "destroy 10,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "16,000"),
	}),
	Milestone.new({
		"id": "Blues800",
		"name": "BLUE DESTROYER",
		"unlock_desc": "destroy 800 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "800"),
	}),
	Milestone.new({
		"id": "Yellows5",
		"name": "YELLOW DEFEATER",
		"unlock_desc": "destroy 5 yellow enemies",
		"reward": ResourceType.resource_str(ResourceType.PROCESSORS, "1"),
	}),
	Milestone.new({
		"id": "Reds15k",
		"name": "RED ENDER",
		"unlock_desc": "destroy 15,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "20,000"),
	}),
	Milestone.new({
		"id": "Blues1.2k",
		"name": "BLUE ENDER",
		"unlock_desc": "destroy 1,200 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "1200"),
	}),
	Milestone.new({
		"id": "Yellows10",
		"name": "YELLOW ENEMY",
		"unlock_desc": "destroy 10 yellow enemies",
		"reward": ResourceType.resource_str(ResourceType.PROCESSORS, "1"),
	}),
	Milestone.new({
		"id": "Reds20k",
		"name": "RED RIVAL",
		"unlock_desc": "destroy 20,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "30,000"),
	}),
	Milestone.new({
		"id": "Blues1.6k",
		"name": "BLUE RIVAL",
		"unlock_desc": "destroy 1,500 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "1600"),
	}),
	Milestone.new({
		"id": "Yellows15",
		"name": "YELLOW SLAYER",
		"unlock_desc": "destroy 15 yellow enemies",
		"reward": ResourceType.resource_str(ResourceType.PROCESSORS, "1"),
	}),
	Milestone.new({
		"id": "Reds30k",
		"name": "RED BREAKER",
		"unlock_desc": "destroy 30,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "50,000"),
	}),
	Milestone.new({
		"id": "Blues2k",
		"name": "BLUE BREAKER",
		"unlock_desc": "destroy 2,000 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "2,000"),
	}),
	Milestone.new({
		"id": "Reds50k",
		"name": "RED CHALLENGER",
		"unlock_desc": "destroy 50,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "100,000"),
	}),
	Milestone.new({
		"id": "Blues4k",
		"name": "BLUE CHALLENGER",
		"unlock_desc": "destroy 4,000 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "4,000"),
	}),
	Milestone.new({
		"id": "Reds100k",
		"name": "RED NEMESIS",
		"unlock_desc": "destroy 100,000 red enemies",
		"reward": ResourceType.resource_str(ResourceType.BITS, "1,000,000"),
	}),
	Milestone.new({
		"id": "Blues8k",
		"name": "BLUE NEMESIS",
		"unlock_desc": "destroy 8,000 blue enemies",
		"reward": ResourceType.resource_str(ResourceType.NODES, "8,000"),
	}),
]

var _data_dict: Dictionary = {}

func _ready() -> void:
	for upgrade: Milestone in data:
		_data_dict[upgrade.id] = upgrade

func search(milestone_id: String) -> Milestone:
	return _data_dict.get(milestone_id, null)


func reset() -> void:
	for milestone: Milestone in data:
		milestone.claimed = false

func save() -> Dictionary:
	# Key: Upgrade id, Value: milestone claimed
	var save: Dictionary = {}
	for milestone: Milestone in data:
		save[milestone.id] = milestone.claimed
	return save

func load_save(save: Dictionary) -> void:
	reset()
	for milestone_id: String in save:
		var milestone: Milestone = search(milestone_id)
		if milestone:
			milestone.claimed = save[milestone_id]
