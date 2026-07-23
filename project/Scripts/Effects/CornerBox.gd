class_name CornerBox
extends NinePatchRect

@onready var color_rect: ColorRect = %ColorRect

var width: float
var color: Color

func set_width(_width: float) -> void:
	width = _width
	size = Vector2(width, width)
	pivot_offset = size/2

func set_color(_color: Color) -> void:
	color = _color
	modulate = color

var _pulse_t: Tween
func pulse(base_dangle: float = 0) -> void:
	modulate = MyColors.WHITE
	Springer.scale(self, 16/size.x, 1, 500)
	Springer.rotate(self, Utils.flipi()*8, base_dangle)
	await MyTimer.wait(0.1)
	modulate = color

func flicker_out() -> void:
	var t = MyTimer.create_repeating(0.04, 1.0, 6)
	t.repeated.connect(func(): visible = not visible)
	t.completed.connect(queue_free)
