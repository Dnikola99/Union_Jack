class_name PlayerInputManipulator
extends InputManipulator

func _input(event: InputEvent) -> void:
	var raw_input:Vector2 = Input.get_vector("Left", "Right", "Down", "Up")
	var cam_basis:Basis = get_viewport().get_camera_3d().global_transform.basis
	var forward:Vector3 = cam_basis.z
	var right:Vector3 = cam_basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	var dir:Vector3 = (right * raw_input.x) + (forward * -raw_input.y)
	input_state.input_direction = Vector2(dir.x, dir.z)
