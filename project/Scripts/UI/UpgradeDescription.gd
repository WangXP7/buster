class_name UpgradeDescription
extends ScreenControl

@onready var upgrade_name: RichTextLabel = %UpgradeName
@onready var upgrade_icon: UpgradeIcon = %UpgradeIcon
@onready var description: RichTextLabel = %Description
@onready var level: RichTextLabel = %Level
@onready var cost_panel: PanelContainer = %CostPanel
@onready var cost: RichTextLabel = %Cost

var upgrade: Upgrade

func _process(delta: float) -> void:
	if is_visible_in_tree():
		update_cost_text()

var spr
func show_upgrade_node(upgrade_node: UpgradeNode) -> void:
	scale = Vector2.ONE
	rotation = 0
	show()
	load_upgrade(upgrade_node.upgrade)
	center_above_or_below(upgrade_node)
	attach(upgrade_node)
	
	pivot_offset = size/2
	var springs: Array[Spring] = Springer.squash(self, -0.3, 0.5, 1, 1000, 18)
	for spring: Spring in springs: spring.set_range(0.5, 1.5)
	Springer.rotate(self, 8).set_range(-10, 10)

func load_upgrade(_upgrade: Upgrade) -> void:
	upgrade = _upgrade
	upgrade_icon.load_upgrade(upgrade)
	refresh_ui()

func refresh_ui() -> void:
	if not upgrade: return
	upgrade_name.text = upgrade.name
	description.text = "[center]%s[/center]" % upgrade.description
	level.text = "[center]Lv. %d / %d[/center]" % [upgrade.curr_level, upgrade.get_max_level()]
	
	update_cost_text()
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)

func update_cost_text() -> void:
	if not upgrade: return
	
	if upgrade.is_maxed():
		cost.text = "[center]MAX[/center]"
		cost_panel.self_modulate = lerp(MyColors.YELLOW, MyColors.BG, 0.4)
	else:
		cost.text = "[center]%s[/center]" % \
				ResourceType.resource_str(upgrade.resource_type,
				"%s / %s" % [Utils.num_str(State.get_resource(upgrade.resource_type)),
				Utils.num_str(upgrade.get_cost())])
		if upgrade.can_buy():
			cost_panel.self_modulate = lerp(MyColors.GREEN, MyColors.BG, 0.7)
		else:
			cost_panel.self_modulate = lerp(MyColors.RED, MyColors.BG, 0.7)

func spring_level_up() -> void:
	level.pivot_offset = level.size/2
	Springer.squash(level, -0.3, 0.6)
	Springer.rotate(level, 6)
	
	cost.pivot_offset = cost.size/2
	Springer.squash(cost, -0.3, 0.6)
	Springer.rotate(cost, -6)
