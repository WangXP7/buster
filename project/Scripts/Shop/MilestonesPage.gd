class_name MilestonesPage
extends Node2D

const _milestone_entry = preload("res://Scenes/Shop/MilestoneEntry.tscn")

@onready var milestone_vbox: VBoxContainer = %MilestoneVBox
@onready var notification_dot: TextureRect = %NotificationDot

func _ready() -> void:
	for milestone: Milestone in MilestoneStore.data:
		var entry: MilestoneEntry = _milestone_entry.instantiate()
		milestone_vbox.add_child(entry)
		entry.load_milestone(milestone)
		entry.claimed.connect(_on_milestone_claimed.bind(entry))
	update_notification_dot()

func _on_milestone_claimed(entry: MilestoneEntry) -> void:
	entry.set_claimed()
	Refs.upgrade_processor.gain_milestone(entry.milestone)
	update_notification_dot()

func update_notification_dot() -> void:
	notification_dot.hide()
	for entry: MilestoneEntry in milestone_vbox.get_children():
		if entry.is_claimable():
			notification_dot.show()
