class_name GameCamera
extends Camera3D

@export var target:Node3D
@export var max_distance:float = 2
@export var target_y:float = 1.5

func _process(delta: float) -> void:
	var target_position:Vector3 = target.global_position
	target_position.y += target_y
	var dir_vec:Vector3 = global_position - target_position
	dir_vec.y = 0
	var dist:float = dir_vec.length()
	if dist > max_distance :
		position -= dir_vec.normalized() * (dist - max_distance) * delta * 10.0
	look_at(target_position)
