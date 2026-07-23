class_name LabPage
extends Node2D

@onready var research_progress_bar: TextureProgressBar = %ResearchProgressBar
@onready var research_progress_text: RichTextLabel = %ResearchProgressText
@onready var deposit_btn: TextButton = %LabDepositBtn

@onready var virus_vbox: VBoxContainer = %VirusVBox
@onready var godvirus_texture: TextureRect = %GodvirusTexture
@onready var deploy_virus_btn: TextButton = %DeployVirusBtn

@onready var help_btn: TextButton = %LabHelpBtn

@onready var virus_already_deployed: Label = %VirusAlreadyDeployed


# Curr value of bar, for tweening purposes
var curr_stored_val: float = 0.0
var val_t: Tween

var elapsed_time: float

func _ready() -> void:
	help_btn.hovered.connect(_on_help_hovered)
	help_btn.unhovered.connect(_hide_tooltip)
	deposit_btn.pressed.connect(_on_deposit_pressed)
	deploy_virus_btn.pressed.connect(_on_deploy_virus_pressed)
	research_progress_bar.max_value = 1000
	curr_stored_val = State.lab_research_progress
	update_progress()
	
	if State.virus_deployed:
		virus_already_deployed.show()
		virus_vbox.hide()
		deposit_btn.hide()
		research_progress_bar.hide()
		research_progress_text.hide()
		$PanelContainer/MarginContainer/VBoxContainer/ResearchProgressTag.hide()
	else:
		virus_already_deployed.hide()

func _process(delta: float) -> void:
	if not is_visible_in_tree() or State.virus_deployed: return
	
	deposit_btn.btn_text = "deposit %s" % ResourceType.resource_str(ResourceType.NETCOIN,
			Utils.num_str(State.netcoin))
	update_progress()
	
	elapsed_time += delta
	var atlas: AtlasTexture = godvirus_texture.texture
	atlas.region.position.x = snappedi(elapsed_time*32*10, 32) % 160
	
	if val_t and val_t.is_running():
		SFX.play(Sound.TICK, 0, 0, val_t.get_total_elapsed_time(), 2)

func update_progress() -> void:
	research_progress_bar.value = curr_stored_val
	research_progress_text.text = "[center]%s\n/ %s[/center]" % \
			[ResourceType.resource_str(ResourceType.NETCOIN,
				Utils.num_str(curr_stored_val)),
			ResourceType.resource_str(ResourceType.NETCOIN,
				Utils.num_str(1000.0))]
	virus_vbox.visible = curr_stored_val >= 1000
	deposit_btn.visible = curr_stored_val < 1000
	deposit_btn.set_enabled(State.netcoin != 0.0)

func _on_deposit_pressed() -> void:
	State.lab_research_progress = clamp(State.lab_research_progress+State.netcoin,0,1000)
	State.netcoin = 0.0
	Refs.curr_scn.squash_resource(ResourceType.NETCOIN)
	
	if val_t: val_t.kill()
	val_t = create_tween()
	val_t.tween_property(self, "curr_stored_val", State.lab_research_progress, 0.4) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _on_deploy_virus_pressed() -> void:
	var ending: Ending = preload("res://Scenes/Ending.tscn").instantiate()
	Refs.curr_scn.add_child(ending)
	ending.start_ending()
	State.virus_deployed = true
	Saver.save_game()


func _on_help_hovered() -> void:
	Refs.tooltip.set_text("Invest %s into developing the godvirus." % ResourceType.resource_name(ResourceType.NETCOIN))
	Refs.tooltip.center_above_or_below(help_btn)

func _hide_tooltip() -> void:
	Refs.tooltip.hide()
