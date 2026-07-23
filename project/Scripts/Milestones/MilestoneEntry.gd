class_name MilestoneEntry
extends PanelContainer

signal claimed()

@onready var icon: TextureRect = %Icon
@onready var milestone_name: RichTextLabel = %MilestoneName
@onready var unlock_condition: RichTextLabel = %UnlockCondition
@onready var reward: RichTextLabel = %Reward
@onready var claim_btn: TextButton = %ClaimBtn

var milestone: Milestone

func _ready() -> void:
	claim_btn.pressed.connect(_on_claimed)

func load_milestone(_milestone: Milestone) -> void:
	milestone = _milestone
	
	var progress: float = clamp(Refs.upgrade_processor.check_milestone(milestone), 0.0, 1.0)
	claim_btn.set_enabled(progress >= 1.0)
	
	icon.texture = milestone.icon
	milestone_name.text = milestone.name
	unlock_condition.text = "%s %s(%.1f%%)[/color]" % [milestone.unlock_desc,
			Utils.hex(MyColors.GREEN), progress*100.0]
	reward.text = Utils.colored("REWARD: " + milestone.reward, MyColors.YELLOW)
	
	if milestone.claimed:
		set_claimed()

func is_claimable() -> bool:
	return not claim_btn.disabled

func set_claimed() -> void:
	modulate = lerp(Color.WHITE, MyColors.BG, 0.7)
	claim_btn.set_enabled(false)
	claim_btn.btn_text = "claimed"
	milestone.claimed = true

func _on_claimed() -> void:
	claimed.emit()
