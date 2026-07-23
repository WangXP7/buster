class_name UpgradeTree
extends Node2D

@onready var connection_holder: Node2D = %Connections

@onready var bg_particles: GPUParticles2D = %BGParticles
@onready var bg_particles2: GPUParticles2D = %BGParticles2

# Key: UpgradeNode, Value: Array[UpgradeNode] of all its connections
var connections: Dictionary = {}

# Upgrade tree's rect (using only visible nodes)
var top_left: Vector2 = Vector2(999, 999)
var bot_right: Vector2 = Vector2(-999, -999)

func _ready() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is UpgradeNode:
			for connected_node: UpgradeNode in child.connected_nodes:
				create_connection(child, connected_node)
				# Make sure all nodes are connected both ways
				if not connected_node.connected_nodes.has(child):
					connected_node.connected_nodes.append(child)
			
			child.hovered.connect(_on_hover_upgrade.bind(child))
			child.unhovered.connect(_on_unhover_upgrade)
			child.clicked.connect(_on_upgrade_clicked.bind(child))
	
	for child: Node in children:
		if child is UpgradeNode:
			update_upgrade_visiblity(child)

func create_connection(node1: UpgradeNode, node2: UpgradeNode) -> void:
	if connections.has(node1):
		if connections[node1].has(node2): return
	else:
		connections[node1] = []
	if connections.has(node2):
		if connections[node2].has(node1): return
	else:
		connections[node2] = []
	
	var connection: Line2D = Line2D.new()
	connection.default_color = MyColors.WHITE
	connection.width = 1
	connection_holder.add_child(connection)
	connection.points = [node1.get_center(), node2.get_center()]
	
	connections[node1].append(node2)
	connections[node2].append(node1)
	
	node1.connect_lines[node2] = connection
	node2.connect_lines[node1] = connection

func _on_hover_upgrade(upgrade_node: UpgradeNode) -> void:
	Refs.upgrade_description.show_upgrade_node(upgrade_node)

func _on_unhover_upgrade() -> void:
	Refs.upgrade_description.hide()

func refresh_all_nodes() -> void:
	for node: UpgradeNode in connections:
		node.refresh_ui()

func update_upgrade_visiblity(upgrade_node: UpgradeNode) -> void:
	upgrade_node.visible = Refs.upgrade_processor.check_upgrade_unlocked(upgrade_node)
	if upgrade_node.upgrade.curr_level == 0:
		upgrade_node.modulate = lerp(Color.WHITE, MyColors.BG, 0.5)
	else:
		upgrade_node.modulate = Color.WHITE
	
	# Update tree's rect
	if upgrade_node.visible:
		top_left.x = min(top_left.x, upgrade_node.position.x)
		top_left.y = min(top_left.y, upgrade_node.position.y)
		bot_right.x = max(bot_right.x, upgrade_node.position.x+upgrade_node.size.x)
		bot_right.y = max(bot_right.y, upgrade_node.position.y+upgrade_node.size.y)
	
	# Node isn't visible: hide all connections
	if not upgrade_node.visible:
		for connected_node: UpgradeNode in upgrade_node.connect_lines:
			upgrade_node.connect_lines[connected_node].hide()
	# Node is visible: show all connections to other visible nodes
	else:
		for connected_node: UpgradeNode in upgrade_node.connect_lines:
			if connected_node.visible:
				upgrade_node.connect_lines[connected_node].show()

func _on_upgrade_clicked(upgrade_node: UpgradeNode) -> void:
	var upgrade: Upgrade = upgrade_node.upgrade
	if not upgrade.can_buy(): return
	var cost = upgrade.get_cost()
	State.lose_resource(upgrade.resource_type, cost)
	Refs.curr_scn.squash_resource(upgrade.resource_type)
	
	upgrade.curr_level += 1
	Refs.upgrade_processor.gain_upgrade(upgrade, upgrade.curr_level)
	
	Refs.upgrade_description.refresh_ui()
	Refs.upgrade_description.spring_level_up()
	upgrade_node.refresh_ui()
	upgrade_node.spring()
	
	update_upgrade_visiblity(upgrade_node)
	for connected_node: UpgradeNode in upgrade_node.connected_nodes:
		update_upgrade_visiblity(connected_node)


const hori_offset: float = 100
const verti_offset: float = 100
var _real_pos: Vector2
func set_tree_pos(pos: Vector2) -> void:
	if pos.x + bot_right.x < hori_offset:
		pos.x = hori_offset-bot_right.x
	if pos.y + bot_right.y < verti_offset:
		pos.y = verti_offset-bot_right.y
	if pos.x + top_left.x >= Globals.SIZE.x-hori_offset:
		pos.x = Globals.SIZE.x-hori_offset-top_left.x
	if pos.y + top_left.y >= Globals.SIZE.y-verti_offset:
		pos.y = Globals.SIZE.y-verti_offset-top_left.y
	_real_pos = pos
	position = snapped(_real_pos, Vector2.ONE)
	
	bg_particles.position = Globals.SIZE/2+pos*0.1
	bg_particles2.position = Globals.SIZE/2+pos*0.2

# Give a vector2 to move the tree that amount relative to curr pos
func move_tree(vec: Vector2) -> void:
	set_tree_pos(_real_pos + vec)
