class_name ElectricityEffect
extends Node2D

var lines: Array = []
var to: Vector2

var line_width: float = 2.0
var width: float = 6.0

# colors: should be an array of Colors. One Line2D will be created for each element
# from and to should be global positions
func _init(colors: Array, _from: Vector2, _to: Vector2,
_width: float = 6.0, _line_width: float = 2.0) -> void:
	position = _from
	to = _to
	width = _width
	line_width = _line_width
	
	for color in colors:
		var line = Line2D.new()
		line.default_color = color
		add_child(line)
		lines.append(line)
	
	set_line_width(line_width)

func _ready():
	update_all()

func update_all():
	for line in lines:
		update_effect(line)

func update_effect(line: Line2D) -> void:
	var from = Vector2.ZERO
	var local_to = to_local(to)
	
	var dir = (local_to - from).normalized()
	var perp = Utils.perp_ccw(dir)
	
	var dist = from.distance_to(local_to)
	var num_vertices = 1 + int(ceil(dist / 15.0))
	
	var points = []
	points.resize(2 + num_vertices)
	
	points[0] = from
	
	var distances = []
	distances.resize(num_vertices)
	
	for i in range(distances.size()):
		var prev_dist = (dist / num_vertices) * i
		var this_dist = prev_dist + (dist / num_vertices) * randf_range(0.7, 1.3)
		distances[i] = this_dist
		
		var point = from + this_dist * dir
		point += perp * randf_range(-(width + 6), (width + 6))
		
		points[i + 1] = point
	
	points[-1] = local_to
	
	line.points = points

func set_line_width(lw: float) -> void:
	line_width = lw
	for line in lines:
		line.width = lw

func tween_width(end_width: float, duration: float) -> MethodTweener:
	var tween = create_tween()
	return tween.tween_method(set_line_width, line_width, end_width, duration)\
		.set_trans(Tween.TRANS_LINEAR)

