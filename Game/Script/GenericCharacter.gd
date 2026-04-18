class_name  GenericCharacter
extends CharacterBody3D

@export var animation_tree:AnimationTree
@export var reponsiveness:float = 10.0
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
	animation_tree.set("parameters/StateMachine/idle/blend_position", input_vector)
	animation_tree.set("parameters/StateMachine/idle_combat_no_weapon/blend_position", input_vector)
	
	if delta > 0:
		var motion = animation_tree.get_root_motion_position()
		velocity = motion / delta
		move_and_slide()
