extends Node3D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	open()


func open():
	animationPlayer.play("Open")
