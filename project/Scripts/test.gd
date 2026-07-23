extends Node2D

@onready var enemy_drops_layer: int = Layers.bitmask(["EnemyDrops"])

func _ready() -> void:
	$Area2D.area_entered.connect(_bla)

func _physics_process(delta: float) -> void:
	global_position = Globals.mouse_pos
	var results: Array[Dictionary] = ShapeCaster.circle_cast(global_position,
			64, 1, [$Area2D], true, false, 128)
	for result: Dictionary in results:
		print("CCCC")

func _bla(area: Area2D) -> void:
	print("AAAA!")

