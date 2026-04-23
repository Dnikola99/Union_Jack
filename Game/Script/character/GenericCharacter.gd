class_name  GenericCharacter
extends CharacterBody3D

@export var animation_tree:AnimationTree
@export var reponsiveness:float = 2
enum ColliderType{
	HAND_RIGHT,
	HAND_LEFT,
	FOOT_RIGHT,
	FOOT_LEFT
}
@export var right_hand_collider:Area3D
@export var left_hand_collider:Area3D
@export var right_foot_collider:Area3D
@export var left_foot_collider:Area3D
enum CharacterInputType{
	AI,
	CONTROLER
}
@export_enum("AI","CONTROLER") var input_type:int = 0

var input_state:InputState
var input_vector:Vector2
var input_manipulator:InputManipulator
var processing_attack_sequence:bool = false
var combat_counter:float = 0.0
var animation_tree_playback:AnimationNodeStateMachinePlayback

var connected_collision:Array = [null,null,null,null]
var colliders:Array

func _ready() -> void:
	colliders = [
		right_hand_collider,
		left_hand_collider,
		right_foot_collider,
		left_foot_collider]
	input_state = InputState.new()
	input_vector = Vector2.ZERO
	animation_tree_playback = animation_tree.get("parameters/StateMachine/playback")
	
	match  input_type :
		CharacterInputType.AI:
			input_manipulator = InputManipulator.new(input_state)
		CharacterInputType.CONTROLER :
			input_manipulator = PlayerInputManipulator.new(input_state)
	add_child(input_manipulator)
	
	right_hand_collider.body_entered.connect(Callable(self,"body_enter").bind(ColliderType.HAND_RIGHT))
	right_hand_collider.body_exited.connect(Callable(self,"body_exit").bind(ColliderType.HAND_RIGHT))
	left_hand_collider.body_entered.connect(Callable(self,"body_enter").bind(ColliderType.HAND_LEFT))
	left_hand_collider.body_exited.connect(Callable(self,"body_exit").bind(ColliderType.HAND_LEFT))
	
	right_foot_collider.body_entered.connect(Callable(self,"body_enter").bind(ColliderType.FOOT_RIGHT))
	right_foot_collider.body_exited.connect(Callable(self,"body_exit").bind(ColliderType.FOOT_RIGHT))
	left_foot_collider.body_entered.connect(Callable(self,"body_enter").bind(ColliderType.FOOT_LEFT))
	left_foot_collider.body_exited.connect(Callable(self,"body_exit").bind(ColliderType.FOOT_LEFT))
	
func body_enter(b, t:ColliderType):
	if b is Area3D : return
	connected_collision[t] = b
	
func body_exit(b, t:ColliderType):
	if b == connected_collision[t] :
		connected_collision[t] = null
		
func do_damage(t:ColliderType):
	print("do damage")
	if connected_collision[t] is GenericCharacter : 
		# collide with other character
		var victim:GenericCharacter = connected_collision[t] as GenericCharacter
		victim.get_damage(colliders[t].global_position)
		print("hit")
	
func get_damage(pos:Vector3):
	var d_height:float = to_local(pos).y
	if d_height < 0.6 :
		# mid attack
		animation_tree_playback.travel("medium")
	else :
		# high attack
		animation_tree_playback.travel("high")
		pass
		
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
		reset_input()
		
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
				InputState.Action.HEAVY :
					animation_tree.set("parameters/StateMachine/conditions/H", true)
