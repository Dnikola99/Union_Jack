extends Node3D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer


func open():
	animationPlayer.play("Open")
