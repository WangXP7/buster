class_name ConfirmationPopup
extends PanelContainer

# True if yes, False if no
signal chosen(val: bool)

@onready var message: RichTextLabel = %Message
@onready var no: TextButton = %No
@onready var yes: TextButton = %Yes


func _ready() -> void:
	no.pressed.connect(_on_no)
	yes.pressed.connect(_on_yes)

func setup(message_str: String, no_msg: String = "no", yes_msg: String = "yes") -> void:
	message.text = "[center]%s[/center]" % message_str
	no.btn_text = no_msg
	yes.btn_text = yes_msg

func _on_no() -> void:
	chosen.emit(false)

func _on_yes() -> void:
	chosen.emit(true)

