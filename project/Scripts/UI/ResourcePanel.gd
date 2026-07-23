class_name ResourcePanel
extends PanelContainer

signal hovered()
signal unhovered()

@onready var resource_icon: TextureRect = %ResourceIcon
@onready var amount_text: RichTextLabel = %AmountText

var resource_type: int
var amount

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_resource_type(_resource_type: int) -> void:
	resource_type = _resource_type
	resource_icon.texture = ResourceType.get_icon(resource_type)
	amount_text.add_theme_color_override("default_color",
			ResourceType.get_color(resource_type))
	
	State.get_resource_changed_signal(resource_type).connect(refresh_ui)
	refresh_ui()

func refresh_ui() -> void:
	amount = State.get_resource(resource_type)
	amount_text.text = "[right]%s[/right]" % Utils.num_str(amount)

func squash() -> void:
	amount_text.pivot_offset = amount_text.size/2
	var magnitude: float = 9/amount_text.size.x
	Springer.squash(amount_text, -magnitude, magnitude)
	Springer.rotate(amount_text, 16)
	
	amount_text.add_theme_color_override("default_color", MyColors.WHITE)
	await MyTimer.wait(0.1)
	amount_text.add_theme_color_override("default_color",
			ResourceType.get_color(resource_type))

func _on_mouse_entered() -> void:
	hovered.emit()

func _on_mouse_exited() -> void:
	unhovered.emit()
