class_name UpgradeNode
extends Control

signal hovered()
signal unhovered()
signal clicked()


@export var upgrade_id: String
@export var connected_nodes: Array[UpgradeNode] = []

@onready var upgrade_icon: UpgradeIcon = %UpgradeIcon
@onready var button: Button = %Button

# Built at runtime. Key: connected UpgradeNode, Value: Line2D that connects me to that node
var connect_lines: Dictionary = {}

var upgrade: Upgrade


func _ready() -> void:
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	button.button_down.connect(_on_btn_down)
	button.button_up.connect(_on_btn_up)
	button.pressed.connect(_on_btn_pressed)
	
	upgrade = UpgradeStore.search(upgrade_id)
	upgrade_icon.load_upgrade(upgrade)
	
	State.get_resource_changed_signal(upgrade.resource_type).connect(refresh_ui)
	
	refresh_ui()

func refresh_ui() -> void:
	upgrade_icon.setup_outline_color()

func get_center() -> Vector2:
	return global_position + size/2

func spring() -> void:
	Springer.scale(upgrade_icon, 0.4)
	Springer.rotate(upgrade_icon, 12)

func _on_mouse_entered() -> void:
	hovered.emit()
	SFX.play(Sound.BUTTON_HOVER, 0.1)

func _on_mouse_exited() -> void:
	unhovered.emit()

func _on_btn_pressed() -> void:
	clicked.emit()

func _on_btn_down() -> void:
	SFX.play(Sound.BUTTON_DOWN)

func _on_btn_up() -> void:
	SFX.play(Sound.BUTTON_UP)
