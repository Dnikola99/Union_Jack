extends StateBase

var pushBackDir : Vector3
var pushBackSpeed : float = 50

@export var materialEffectAnimationPlayer : AnimationPlayer

func enter():
	super.enter()
	character.velocity = Vector3.ZERO
	materialEffectAnimationPlayer.play("Hurt_Flash")
	
	if character.currentHealth == 0:
		state_machine.switchTo("Dead")
	
	
func state_update(_delta:float):
	
	character.velocity = pushBackDir * pushBackSpeed * _delta
	
	if animationPlayer.is_playing() == false:
		state_machine.switchTo("Idle")



func exit():
	super.exit()
	character.velocity = Vector3.ZERO
