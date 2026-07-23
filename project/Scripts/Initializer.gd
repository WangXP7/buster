class_name Initializer
extends Node

func _ready() -> void:
	if get_parent() is ShopScene:
		Refs.upgrade_description = %UpgradeDescription
		Refs.upgrade_tree = %UpgradeTree
	elif get_parent() is BattleScene:
		Refs.health = %HealthBar
		Refs.xp = %XPBar
		Refs.enemy_spawner = %EnemySpawner
		Refs.drop_creator = %EnemyDropsCreator
