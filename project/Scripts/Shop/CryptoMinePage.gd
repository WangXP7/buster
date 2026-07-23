class_name CryptoMinePage
extends Node2D

@onready var conversion_rate: RichTextLabel = %ConversionRate
@onready var deposited_bits: StatEntry = %DepositedBits
@onready var netcoin_returns: StatEntry = %NetcoinReturns
@onready var time_remaining: StatEntry = %TimeRemaining
@onready var deposit_btn_grid: GridContainer = %DepositBtnGrid
@onready var deposit_button: TextButton = %DepositButton
@onready var conversion_speed: RichTextLabel = %ConversionSpeed
@onready var upgrade_mine_btn: TextButton = %UpgradeMineBtn

@onready var help_btn: TextButton = %CryptoMineHelpBtn


# Deposit button values
var deposit_values: Array[int] = [1000, 5000, 10000, 50000, 100000, 1000000]
var deposit_btns: Array[TextButton]

func _ready() -> void:
	help_btn.hovered.connect(_on_help_hovered)
	help_btn.unhovered.connect(_hide_tooltip)
	conversion_rate.mouse_entered.connect(_on_label_mouse_entered.bind(conversion_rate,
			"The conversion rate of %s to %s" %\
			[ResourceType.resource_name(ResourceType.BITS),
			ResourceType.resource_name(ResourceType.NETCOIN)]))
	conversion_rate.mouse_exited.connect(_hide_tooltip)
	conversion_speed.mouse_entered.connect(_on_label_mouse_entered.bind(conversion_speed,
			"The current speed of conversion. Upgrade to improve the speed."))
	conversion_speed.mouse_exited.connect(_hide_tooltip)
	deposited_bits.stat_desc = "Amount of deposited %s that are currently being processed"%\
			ResourceType.resource_name(ResourceType.BITS)
	netcoin_returns.stat_desc = "Total amount of %s that the deposited %s will convert into"%\
			[ResourceType.resource_name(ResourceType.NETCOIN),
			ResourceType.resource_name(ResourceType.BITS)]
	time_remaining.stat_desc = "Time until all deposited %s are converted into %s" %\
			[ResourceType.resource_name(ResourceType.BITS),
			ResourceType.resource_name(ResourceType.NETCOIN)]
	
	conversion_rate.text = "[center]%s -> %s[/center]" %\
			[ResourceType.resource_str(ResourceType.BITS, "1"),
			ResourceType.resource_str(ResourceType.NETCOIN, "0.00001")]
	
	upgrade_mine_btn.btn_text = "upgrade speed (%s)" % \
			ResourceType.resource_str(ResourceType.PROCESSORS, "1")
	upgrade_mine_btn.pressed.connect(_on_upgrade_pressed)
	State.processors_changed.connect(_on_processors_changed)
	_on_processors_changed()
	
	# Build deposit buttons
	var deposit_strings: Array[String] = ["1k", "5k", "10k", "50k", "100k", "1m"]
	for i: int in deposit_strings.size():
		var btn: TextButton = deposit_button
		if i != 0:
			btn = btn.duplicate()
			deposit_btn_grid.add_child(btn)
		btn.btn_text = "%s %s" % [ResourceType.get_icon_bbcode(ResourceType.BITS),
				deposit_strings[i]]
		deposit_btns.append(btn)
		btn.pressed.connect(_on_deposit_pressed.bind(i))
	
	State.bits_changed.connect(_on_bits_changed)
	_on_bits_changed()
	
	conversion_speed.text = "[center]conversion_speed: %s/sec[/center]" % \
			ResourceType.resource_str(ResourceType.BITS, "5")

func _process(delta: float) -> void:
	deposited_bits.setup("deposited", ResourceType.resource_str(ResourceType.BITS,
			str(int(ceil(State.crypto_mine.curr_bits)))))
	
	netcoin_returns.setup("netcoin_returns", ResourceType.resource_str(ResourceType.NETCOIN,
			Utils.num_str(State.crypto_mine.get_netcoin_returns())))
	
	var time_to_complete: float = State.crypto_mine.get_time_remaining()
	var minutes = int(floor(time_to_complete / 60))
	var seconds = int(floor(fmod(time_to_complete, 60)))
	var time_str: String = "%02d:%02d" % [minutes, seconds]
	time_remaining.setup("time_remaining", Utils.colored(time_str, MyColors.YELLOW))
	
	conversion_speed.text = "[center]conversion_speed: %s/sec[/center]" %\
			ResourceType.resource_str(ResourceType.BITS, str(State.crypto_mine.curr_speed))
	_refresh_upgrade_btn()

func _on_bits_changed() -> void:
	for i: int in deposit_btns.size():
		var amount: int = deposit_values[i]
		var btn: TextButton = deposit_btns[i]
		btn.set_enabled(State.bits >= amount)

func _on_deposit_pressed(idx: int) -> void:
	var amount: int = deposit_values[idx]
	State.bits -= amount
	Refs.curr_scn.squash_resource(ResourceType.BITS)
	State.crypto_mine.deposit(amount)
	deposited_bits.squash_value()
	SFX.play(Sound.PLINK)

func _on_upgrade_pressed() -> void:
	State.processors -= 1
	Refs.curr_scn.squash_resource(ResourceType.PROCESSORS)
	State.crypto_mine.level_up()
	
	conversion_speed.pivot_offset = conversion_speed.size/2
	Springer.squash(conversion_speed, -0.1, 0.1)
	Springer.rotate(conversion_speed, 4)
	Jumper.jump(conversion_speed, Vector2.UP, 4, 0.1)
	_refresh_upgrade_btn()

func _on_processors_changed() -> void:
	_refresh_upgrade_btn()

func _refresh_upgrade_btn() -> void:
	if State.crypto_mine.is_maxed():
		upgrade_mine_btn.set_enabled(false)
	else:
		upgrade_mine_btn.set_enabled(State.processors >= 1)

func _on_label_mouse_entered(label: Control, tooltip: String) -> void:
	label.pivot_offset = label.size/2
	Refs.tooltip.set_text(tooltip)
	Refs.tooltip.center_above_or_below(label)
	SFX.play(Sound.BUTTON_HOVER, 0.2)
	Springer.squash(label, 0.4, 0.2)

func _hide_tooltip() -> void:
	Refs.tooltip.hide()

func _on_help_hovered() -> void:
	Refs.tooltip.set_text("Deposit %s and they will automatically be converted into %s over time.\nSpend %s to improve the conversion speed." % [ResourceType.resource_name(ResourceType.BITS), ResourceType.resource_name(ResourceType.NETCOIN), ResourceType.resource_name(ResourceType.PROCESSORS)])
	Refs.tooltip.center_above_or_below(help_btn)

