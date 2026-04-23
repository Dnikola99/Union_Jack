class_name  GenericCharacter
extends CharacterBody3D

@export var animation_tree:AnimationTree
@export var reponsiveness:float = 2
@export var right_hand_collider:Area3D
@export var left_hand_collider:Area3D
@export var right_hand_weapon_collider:Area3D
@export var left_hand_weapon_collider:Area3D
@export var right_foot_collider:Area3D
@export var left_foot_collider:Area3D

var input_state:InputState
var input_vector:Vector2
var input_manipulator:InputManipulator
var processing_attack_sequence:bool = false
var combat_counter:float = 0.0

var animation_tree_playback:AnimationNodeStateMachinePlayback
func _ready() -> void:
	input_state = InputState.new()
	input_vector = Vector2.ZERO
	animation_tree_playback = animation_tree.get("parameters/StateMachine/playback")
	
	input_manipulator = PlayerInputManipulator.new(input_state)
	add_child(input_manipulator)
	
func reset_LH():
	animation_tree.set("parameters/StateMachine/conditions/L", false)
	animation_tree.set("parameters/StateMachine/conditions/H", false)
	input_state.LH = false
	processing_attack_sequence = false
	
func reset_input():
	reset_LH()
	input_state.action_sequence.clear()
	
func directionalMovement(delta):
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

func _physics_process(delta):
	directionalMovement(delta)
	if combat_counter <= 0 and animation_tree_playback.get_current_node() != "idle" :
		animation_tree.set("parameters/StateMachine/conditions/combat_no_weapon", false)
		animation_tree_playback.travel("idle")
		
	if not processing_attack_sequence :
		combat_counter = max(combat_counter-delta, 0)
		if input_state.action_sequence.size() > 0 :
			if animation_tree_playback.get_current_node() == "idle" :
				animation_tree.set("parameters/StateMachine/conditions/combat_no_weapon", true)
			var action:InputState.Action = input_state.action_sequence.pop_back()
			processing_attack_sequence = true
			combat_counter = 1
			match action :
				InputState.Action.LIGHT :
					animation_tree.set("parameters/StateMachine/conditions/L", true)
