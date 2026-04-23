class_name InputState

enum Action {
	LIGHT,
	HEAVY,
	BLOCK,
	DODGE
}

# forward bacward left right
# translated to the BlendSpace2D
var input_direction:Vector2 

# sequence of input
# for example LLH LLL for navigating attack states
# see the action enum
var action_sequence:Array[Action]

var LH:bool = false
