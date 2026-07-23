class_name BattleEndScreen
extends Control

signal home_pressed()
signal restart_pressed()

@onready var bg: ColorRect = %BG
@onready var session_terminated: RichTextLabel = %SessionTerminated
@onready var status_text: RichTextLabel = %StatusText
@onready var acquired_resources_tag: RichTextLabel = %AcquiredResourcesTag
@onready var acquired_resources_text: RichTextLabel = %AcquiredResourcesText
@onready var home_btn: TextButton = %HomeBtn
@onready var restart_btn: TextButton = %RestartBtn


func _ready() -> void:
	home_btn.pressed.connect(_on_home_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)

# code: 0 if health zeroed. 1 if boss defeated. 2 if terminated by user.
func setup(obtained_resources: Dictionary, code: int) -> void:
	if code == 0:
		bg.color = lerp(MyColors.BG, MyColors.RED, 0.2)
		status_text.text = "[center]status code 401: health reached zero[/center]"
		SFX.play(Sound.LOSE, 0, 2)
	elif code == 1:
		bg.color = lerp(MyColors.BG, MyColors.GREEN, 0.2)
		var subtext: String = ""
		if State.curr_prestige < 25:
			subtext=Utils.colored("prestige %d unlocked"%(State.max_prestige+1), MyColors.YELLOW)
		else:
			subtext = "there is nowhere left to go"
		status_text.text = "[center]status code 404: %s\n%s[/center]" % \
				[Utils.colored("boss defeated", MyColors.YELLOW),
				subtext]
		SFX.play(Sound.WIN, 0)
	else:
		bg.color = lerp(MyColors.BG, MyColors.RED, 0.2)
		status_text.text = "[center]status code 500: terminated by user[/center]"
		SFX.play(Sound.LOSE, 0, 2)
	bg.color.a = 0.6
	
	var obtained_resources_str: String = "[center]"
	if obtained_resources.is_empty():
		obtained_resources_str += "none[/center]"
	else:
		for resource_type: int in obtained_resources:
			var amount: int = obtained_resources[resource_type]
			obtained_resources_str += "%s\n" % ResourceType.resource_str(resource_type,
					str(amount))
		obtained_resources_str = obtained_resources_str.left(-1)
	acquired_resources_text.text = obtained_resources_str
	
	var t: Tween = create_tween().set_parallel(true)
	
	var texts: Array[RichTextLabel] = [
		session_terminated, status_text, acquired_resources_tag, acquired_resources_text
	]
	for label: RichTextLabel in texts:
		label.visible_ratio = 0
		t.tween_property(label, "visible_ratio", 1.0, 0.5)
	
	if State.total_bits >= 10000: MySteam.set_achievement("BITS_10K", false)
	if State.total_bits >= 100000: MySteam.set_achievement("BITS_100K", false)
	if State.total_bits >= 1000000: MySteam.set_achievement("BITS_1M", false)
	if State.total_bits >= 10000000: MySteam.set_achievement("BITS_10M", false)
	
	if State.total_nodes >= 1000: MySteam.set_achievement("NODES_1K", false)
	if State.total_nodes >= 10000: MySteam.set_achievement("NODES_10K", false)
	Steam.storeStats()

func _on_home_pressed() -> void:
	home_pressed.emit()

func _on_restart_pressed() -> void:
	restart_pressed.emit()
