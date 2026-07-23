class_name MyCamera
extends Camera2D


func _ready() -> void:
	Refs.camera = self

func shake(magnitude: float = 3, duration: float = 0.3, frequency: float = 70) -> void:
	var strength: float = magnitude*Globals.screenshake_intensity
	Shaker.shake_property(self, "offset:x", strength, duration, frequency)
	Shaker.shake_property(self, "offset:y", strength, duration, frequency)

func _input(event: InputEvent) -> void:
	pass
	#if event is InputEventMouseButton:
		#if event.is_pressed():
			#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				#zoom += Vector2(0.1, 0.1)
			#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				#zoom -= Vector2(0.1, 0.1)
