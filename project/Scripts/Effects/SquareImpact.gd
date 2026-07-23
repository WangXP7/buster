class_name SquareImpact
extends Node2D

var size: Vector2
var color: Color

func setup(_size: Vector2, _color: Color) -> void:
	size = _size
	color = _color
	queue_redraw()
	
	scale = Vector2(1.4, 1.4)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.12)
	
	if Globals.flashing:
		modulate = MyColors.WHITE
	else:
		modulate = color
	await MyTimer.wait(0.08)
	modulate = color
	await MyTimer.wait(0.05)
	queue_free()

func _draw() -> void:
	draw_rect(Rect2(-size/2, size), Color.WHITE)

