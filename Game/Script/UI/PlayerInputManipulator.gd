class_name PlayerInputManipulator
extends InputManipulator

func _input(event: InputEvent) -> void:
	input_state.input_direction = Input.get_vector("Left", "Right", "Down", "Up")
