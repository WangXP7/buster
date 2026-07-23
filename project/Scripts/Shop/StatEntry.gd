class_name StatEntry
extends HBoxContainer

@onready var stat_name: RichTextLabel = %StatName
@onready var stat_value: RichTextLabel = %StatValue

var stat_desc: String

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(stat: String, value) -> void:
	stat_name.text = "[right]%s:[/right]" % stat
	stat_value.text = str(value)

func _on_mouse_entered() -> void:
	pivot_offset = size/2
	Refs.tooltip.set_text(stat_desc)
	Refs.tooltip.center_above_or_below(self)
	SFX.play(Sound.BUTTON_HOVER, 0.2)
	Springer.squash(self, 0.4, 0.2)

func _on_mouse_exited() -> void:
	Refs.tooltip.hide()

func squash_value() -> void:
	var string_size: Vector2 = RTLSizer.get_string_size(stat_value.text)
	stat_value.pivot_offset = string_size/2
	
	var magnitude: float = 9/string_size.x
	Springer.squash(stat_value, -magnitude, magnitude)
	Springer.rotate(stat_value, 16)
