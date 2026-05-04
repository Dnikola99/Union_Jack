extends CharacterBody3D
@export var speed:float=2.5; @export var attack_range:float=1.5; @export var rotation_speed:float=10.0
@onready var navAgent:NavigationAgent3D=$NavigationAgent3D
@onready var visual:Node3D=$VisualNode
@onready var anim:AnimationPlayer=$VisualNode/AnimationPlayer
@onready var flash_anim:AnimationPlayer=$VisualNode/MaterialEffectAnimationPlayer
var player:Node3D; var currentHealth:int; var maxHealth:int=100; var is_attacking:bool=false
func _ready():
	player=get_tree().get_first_node_in_group("Player")
	currentHealth=maxHealth; navAgent.path_desired_distance=0.5; navAgent.target_desired_distance=0.5
func _physics_process(delta:float):
	if not player or is_attacking: return
	navAgent.target_position=player.global_position
	var next_p=navAgent.get_next_path_position(); var dir=(next_p-global_position).normalized()
	var dist=global_position.distance_to(player.global_position)
	if dist>attack_range:
		velocity.x=dir.x*speed; velocity.z=dir.z*speed
		var target_rot=atan2(dir.x,dir.z); visual.rotation.y=lerp_angle(visual.rotation.y,target_rot,rotation_speed*delta)
		anim.play("CouldYouPutTheAnimations?")
	else:
		velocity.x=move_toward(velocity.x,0,speed); velocity.z=move_toward(velocity.z,0,speed)
		if randf()<0.01: execute_ai_attack()
		else: anim.play("CouldYouPutTheAnimations?")
	move_and_slide()
func execute_ai_attack():
	is_attacking=true; var atk_type=str(randi_range(1,3))
	anim.play("CouldYouPutTheAnimations?"+atk_type)
	await anim.animation_finished; is_attacking=false
func applyDamage(damage:int):
	currentHealth=clamp(currentHealth-damage,0,maxHealth); flash_anim.play("Flash")
	if currentHealth<=0: queue_free()
