class_name AnimationConfig extends Resource

@export var animation :StoredAnimation
@export var time_scale:float = 1.0

@export_enum(
	"LOOP_NONE", 
	"LOOP_LINEAR", 
	"LOOP_PINGPONG") var loop : int

enum CollisionType{
	NONE,
	RIGHT_FOOT,
	LEFT_FOOT,
	RIGHT_HAND,
	LEFT_HAND,
	RIGHT_WEAPON,
	LEFT_WEAPON
}

# insert code for checking collision
# select the collider here
@export_enum(
	"NONE",
	"RIGHT_FOOT",
	"LEFT_FOOT",
	"RIGHT_HAND",
	"LEFT_HAND",
	"RIGHT_WEAPON",
	"LEFT_WEAPON")var check_collision:int = 0
	
# keyframe time where to fire the collision check
@export var check_collision_at_time:float = 0

# insert keyframe to reset LH state back to false at the middle of the animation
@export var reset_LH_state:bool = false

@export var reset_input:bool = false
