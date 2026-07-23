class_name ShopScene
extends BaseScene

signal enter_battle()

const _prestige_picker = preload("res://Scenes/Popups/PrestigePicker.tscn")

@onready var bits: ResourcePanel = %Bits
@onready var nodes: ResourcePanel = %Nodes
@onready var cores: ResourcePanel = %Cores
@onready var sp: ResourcePanel = %SP
@onready var netcoin: ResourcePanel = %Netcoin
@onready var processors: ResourcePanel = %Processors

@onready var breach_btn: TextButton = %BreachBtn

@onready var lab_btn: TextButton = %LabBtn
@onready var tab_btns: Array[TextButton] = [
	%UpgradeTabBtn, %MilestonesTabBtn, %CryptoMineTabBtn, %LabBtn, %StatsTabBtn,
]

@onready var pages: Array[Node2D] = [
	%UpgradesPage, %MilestonesPage, %CryptoMinePage, %LabPage, %StatsPage,
]

var curr_page: int

func _ready() -> void:
	breach_btn.pressed.connect(_on_breach_pressed)
	
	bits.set_resource_type(ResourceType.BITS)
	nodes.set_resource_type(ResourceType.NODES)
	cores.set_resource_type(ResourceType.CORES)
	sp.set_resource_type(ResourceType.SP)
	netcoin.set_resource_type(ResourceType.NETCOIN)
	processors.set_resource_type(ResourceType.PROCESSORS)
	
	var resource_panels: Array[ResourcePanel] = [
		bits, nodes, cores, sp, netcoin, processors
	]
	for resource_panel: ResourcePanel in resource_panels:
		resource_panel.hovered.connect(_on_hover_resource.bind(resource_panel.resource_type))
		resource_panel.unhovered.connect(_on_unhover_resource)
	
	for i: int in tab_btns.size():
		tab_btns[i].pressed.connect(set_page.bind(i))
		tab_btns[i].hide()
	set_page(0)
	tab_btns[0].show()
	
	if State.stats.milestones_unlocked:
		show_milestones_btn()
	if State.stats.crypto_mine_unlocked:
		show_crypto_mine_btn()
	if State.stats.lab_unlocked:
		show_lab_btn()

func _process(delta: float) -> void:
	lab_btn.main_color.h = fmod(lab_btn.main_color.h+delta*0.2, 1.0)
	
	bits.visible = curr_page == 0 or curr_page == 2
	nodes.visible = State.nodes_unlocked and curr_page == 0
	cores.visible = State.cores_unlocked and curr_page == 0
	sp.visible = State.sp_unlocked and curr_page == 0
	netcoin.visible = State.netcoin_unlocked and \
			(curr_page == 0 or curr_page == 2 or curr_page == 3)
	processors.visible = State.processors_unlocked and \
			(curr_page == 0 or curr_page == 2)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and not Refs.popups.has_popup() and \
	not Globals.is_mouse_locked():
		SFX.play(Sound.BUTTON_CLICK)
		var game_menu: GameMenu = \
				preload("res://Scenes/Popups/GameMenu.tscn").instantiate()
		Refs.popups.add_popup(game_menu)
		Refs.popups.focus_curr()

func squash_resource(resource_type: int) -> void:
	match resource_type:
		ResourceType.BITS: bits.squash()
		ResourceType.NODES: nodes.squash()
		ResourceType.CORES: cores.squash()
		ResourceType.SP: sp.squash()
		ResourceType.NETCOIN: netcoin.squash()
		ResourceType.PROCESSORS: processors.squash()

func set_page(idx: int) -> void:
	for btn: TextButton in tab_btns:
		btn.set_enabled(true)
	for page: Node2D in pages:
		page.hide()
	tab_btns[idx].set_enabled(false)
	pages[idx].show()
	
	# Stats
	if idx == 4:
		pages[idx].setup()
	
	curr_page = idx

func show_milestones_btn() -> void:
	tab_btns[1].show()
func show_crypto_mine_btn() -> void:
	tab_btns[2].show()
func show_lab_btn() -> void:
	tab_btns[3].show()

func _on_breach_pressed() -> void:
	if State.max_prestige > 0:
		var prestige_picker: PrestigePicker = _prestige_picker.instantiate()
		Refs.popups.add_popup(prestige_picker)
		prestige_picker.setup()
		Refs.popups.focus_curr()
		await prestige_picker.start_btn.pressed
		Refs.popups.pop_curr()
	
	enter_battle.emit()


func _on_hover_resource(resource_type: int) -> void:
	var resource_panel: ResourcePanel
	match resource_type:
		ResourceType.BITS:
			resource_panel = bits
			Refs.tooltip.set_text("%s are a common resource dropped by red enemies." %
					ResourceType.resource_name(ResourceType.BITS))
		ResourceType.NODES:
			resource_panel = nodes
			Refs.tooltip.set_text("%s are an uncommon resource dropped by blue enemies." %
					ResourceType.resource_name(ResourceType.NODES))
		ResourceType.CORES:
			resource_panel = cores
			Refs.tooltip.set_text("%s are a limited resource obtained by defeating bosses. You can only earn one Core per prestige level." %
					ResourceType.resource_name(ResourceType.CORES))
		ResourceType.SP:
			resource_panel = sp
			Refs.tooltip.set_text("%s is a limited resource obtained by leveling up." %
					ResourceType.resource_name(ResourceType.SP))
		ResourceType.NETCOIN:
			resource_panel = netcoin
			Refs.tooltip.set_text("%s is a resource obtained by converting \
					Bits in the Crypto Mine." %
					ResourceType.resource_name(ResourceType.NETCOIN))
		ResourceType.PROCESSORS:
			resource_panel = processors
			Refs.tooltip.set_text("%s are a rare resource dropped by yellow enemies." %\
					ResourceType.resource_name(ResourceType.PROCESSORS))
	resource_panel.pivot_offset = resource_panel.size/2
	Springer.squash(resource_panel, 0.3, 0.5)
	SFX.play(Sound.BUTTON_HOVER)
	Refs.tooltip.center_above_or_below(resource_panel)

func _on_unhover_resource() -> void:
	Refs.tooltip.hide()
