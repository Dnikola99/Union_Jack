class_name AIInputManipulator
extends InputManipulator

var player:GenericCharacter

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	var dir:Vector3 = player.global_position - global_position
	var dist:float= dir.length()
	if dist > 4:
		input_state.input_direction = Vector2(dir.x,dir.z).normalized()
	elif dist <= 4 and dist > 1 :
		input_state.input_direction = Vector2(dir.x,dir.z).normalized() / 2
	else :
		input_state.input_direction = Vector2.ZERO
		if randf() > 0.9 :
			input_state.action_sequence.append(InputState.Action.LIGHT)
		
	
