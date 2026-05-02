class_name  GenericCharacter
extends CharacterBody3D

static var collision_id:int = 1
static func get_collision_id()->int :
	var result:int = GenericCharacter.collision_id
	GenericCharacter.collision_id += 1
	if GenericCharacter.collision_id > 32 :
		GenericCharacter.collision_id = 1
	return result

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
var fall_counter:int = 0						# how many hit before fall
var combat_counter:float = 0.0					# how long before back to movement state
var animation_tree_playback:AnimationNodeStateMachinePlayback

var connected_collision:Array = [null,null,null,null]
var colliders:Array[Area3D]

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
			input_manipulator = AIInputManipulator.new(input_state)
		CharacterInputType.CONTROLER :
			input_manipulator = PlayerInputManipulator.new(input_state)
	add_child(input_manipulator)
	setup_collision_group_and_mask()
	setup_collision_listeners()
	
func setup_collision_group_and_mask():
	var cid:int = GenericCharacter.get_collision_id()
	for i in range(1, 32) :
		set_collision_layer_value(i, i == cid)
		set_collision_mask_value(i, i != cid)
		for c in colliders :
			c.set_collision_layer_value(i, i == cid)
			c.set_collision_mask_value(i, i != cid)
	
func setup_collision_listeners():
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
	if connected_collision[t] is GenericCharacter : 
		# collide with other character
		var victim:GenericCharacter = connected_collision[t] as GenericCharacter
		victim.get_damage(colliders[t].global_position, global_position)
	
func get_y_rotation_to(pos:Vector3):
	return - atan2(pos.z - global_position.z, pos.x- global_position.x) + PI /2
	
func get_damage(pos:Vector3, attacker_pos:Vector3):
	var d_height:float = to_local(pos).y
	fall_counter += 1
	
	if fall_counter >= 3 :
		animation_tree_playback.start("fall")
		fall_counter = 0
	else :
		if (
			animation_tree_playback.get_current_node() == "fall" or
			animation_tree_playback.get_current_node() == "fall_far" 
			):
			animation_tree_playback.start("fall_far")
		else :
			if d_height < 1.2 :
				# mid attack
				animation_tree_playback.start("medium")
			else :
				# high attack
				animation_tree_playback.start("high")
	
	rotation.y = get_y_rotation_to(attacker_pos)
		
func reset_LH():
	animation_tree.set("parameters/StateMachine/conditions/L", false)
	animation_tree.set("parameters/StateMachine/conditions/H", false)
	input_state.LH = false
	processing_attack_sequence = false
	
func reset_input():
	reset_LH()
	input_state.action_sequence.clear()
	
func directionalMovement(delta:float, state:String):
	input_vector = input_vector.lerp(input_state.input_direction, delta * reponsiveness)
	
	var blend_space_pos:Vector3 = to_local(position + Vector3(input_vector.x, 0, input_vector.y))
	var blend_space_2d:Vector2 = Vector2(blend_space_pos.x, blend_space_pos.z)
	animation_tree.set("parameters/StateMachine/idle/blend_position", blend_space_2d)
	animation_tree.set("parameters/StateMachine/combat/blend_position", blend_space_2d)
	
	if state == "combat" or state == "idle" :
		if input_vector.length() > 0 :
			var input_rotation:float = -atan2(input_vector.y, input_vector.x) + PI/2
			rotation.y = input_rotation
		
	if delta > 0:
		var motion = animation_tree.get_root_motion_position()
		motion = global_transform.basis * motion	#transform root motion to global
		velocity = motion / delta
		move_and_slide()

func _physics_process(delta):
	var current_state:String = animation_tree_playback.get_current_node();
	
	directionalMovement(delta, current_state)
	if combat_counter <= 0 and current_state != "idle" :
		animation_tree.set("parameters/StateMachine/conditions/combat", false)
		animation_tree_playback.travel("idle")
		reset_input()
		
	if not processing_attack_sequence :
		combat_counter = max(combat_counter-delta, 0)
		if input_state.action_sequence.size() > 0 :
			if current_state == "idle" :
				animation_tree.set("parameters/StateMachine/conditions/combat", true)
			var action:InputState.Action = input_state.action_sequence.pop_back()
			processing_attack_sequence = true
			combat_counter = 1
			match action :
				InputState.Action.LIGHT :
					animation_tree.set("parameters/StateMachine/conditions/L", true)
				InputState.Action.HEAVY :
					animation_tree.set("parameters/StateMachine/conditions/H", true)
