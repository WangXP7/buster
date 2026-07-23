class_name EnemyDrop2
extends Sprite2D

var resource_type: int
var picked: bool = false

var moving_to_cursor: bool = false
var _lerp_start_pos: Vector2
var _lerp_t: float = 0.0

var rid: RID
var shape: RID

func _ready() -> void:
	rid = PhysicsServer2D.area_create()
	
	shape = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape, 3.0)
	PhysicsServer2D.area_add_shape(rid, shape)
	
	PhysicsServer2D.area_set_monitorable(rid, false)
	
	PhysicsServer2D.area_set_space(rid, get_world_2d().space)
	PhysicsServer2D.area_set_collision_layer(rid, Refs.enemy_drops_mask)
	PhysicsServer2D.area_set_collision_mask(rid, Refs.player_cursor_mask)
	PhysicsServer2D.area_set_area_monitor_callback(rid, _test)
	queue_free()

func set_pos(pos: Vector2) -> void:
	global_position = pos
	PhysicsServer2D.area_set_transform(rid, Transform2D(0, global_position))

func _test(status: int, area_rid: RID, instance_id: int, area_shape_idx: int, self_shape_idx: int) -> void:
	print("BBBBB")

func setup_resource_type(_resource_type: int) -> void:
	resource_type = _resource_type
	if resource_type == ResourceType.BITS:
		texture = preload("res://Sprites/Drops/RedDrop.png")
	elif resource_type == ResourceType.NODES:
		texture = preload("res://Sprites/Drops/BlueDrop.png")
	elif resource_type == ResourceType.PROCESSORS:
		texture = preload("res://Sprites/Drops/YellowDrop.png")
	self_modulate = ResourceType.get_color(resource_type)

func pick_up() -> void:
	if picked: return
	picked = true
	var move_away_dir: Vector2 = Globals.mouse_pos.direction_to(global_position)
	var move_away_dest: Vector2 = global_position + move_away_dir*26
	create_tween().tween_property(self, "global_position", move_away_dest, 0.2) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD) \
			.finished.connect(_on_move_away_finished)
	SFX.play(Sound.PICKUP_START)

func _on_move_away_finished() -> void:
	moving_to_cursor = true
	_lerp_start_pos = global_position

func _process(delta: float) -> void:
	if moving_to_cursor:
		_lerp_t += delta * 6
		global_position = lerp(_lerp_start_pos, Globals.mouse_pos, ease(_lerp_t, 1.5))
		if _lerp_t >= 1.0:
			moving_to_cursor = false
			
			State.gain_resource(resource_type, 1)
			Globals.drop_collected.emit(resource_type, 1)
			
			SFX.play(Sound.PICKUP_RESOURCE, 0.1)
			queue_free()

