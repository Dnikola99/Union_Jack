class_name  GenericCharacter
extends CharacterBody3D

@export var animation_tree:AnimationTree
@export var reponsiveness:float = 2
var input_state:InputState
var input_vector:Vector2
var input_manipulator:InputManipulator

func _ready() -> void:
	input_state = InputState.new()
	input_vector = Vector2.ZERO
	
	input_manipulator = PlayerInputManipulator.new(input_state)
	add_child(input_manipulator)

func _physics_process(delta):
	input_vector = input_vector.lerp(input_state.input_direction, delta * reponsiveness)
	
	var blend_space_pos:Vector3 = to_local(position + Vector3(input_vector.x, 0, input_vector.y))
	var blend_space_2d:Vector2 = Vector2(blend_space_pos.x, blend_space_pos.z)
	animation_tree.set("parameters/StateMachine/idle/blend_position", blend_space_2d)
	animation_tree.set("parameters/StateMachine/idle_combat_no_weapon/blend_position", blend_space_2d)
	
	if input_vector.length() > 0 :
		var input_rotation:float = -atan2(input_vector.y, input_vector.x) + PI/2
		rotation.y = input_rotation
		
	if delta > 0:
		var motion = animation_tree.get_root_motion_position()
		motion = global_transform.basis * motion	#transform root motion to global
		velocity = motion / delta
		move_and_slide()
		
	
