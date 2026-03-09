extends StateBase

@export var collisionShape3D : CollisionShape3D
@export var materialEffectAnimationPlayer : AnimationPlayer

func enter():
	super.enter()
	
	character.velocity = Vector3.ZERO
	collisionShape3D.disabled = true
	
	await get_tree().create_timer(1).timeout
	materialEffectAnimationPlayer.play("Death")
	
	await get_tree().create_timer(3).timeout
	
	var dropItem = preload("res://Game/Scene/collectible_healing_orb.tscn")
	var dropIteminstance = dropItem.instantiate()
	get_tree().get_root().get_node("Node3D").add_child(dropIteminstance)
	dropIteminstance.global_position = character.global_position
	
	character.queue_free()
