extends Node3D

var healthValue: int = 30

@onready var Visual : Node3D = $VisualNode
@onready var VFXanimationPlayer : AnimationPlayer = $VFX/AnimationPlayer



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Visual.visible == false && VFXanimationPlayer.is_playing() == false:
		queue_free()


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		body.AddHealth(healthValue)
		Visual.visible = false
		VFXanimationPlayer.play("PlayParticle")
