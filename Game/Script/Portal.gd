class_name Portal
extends Node3D

var coinRequired : int = 0
@onready var textLabel : Label = $Sprite3D/SubViewport/Label

signal playerReachedThePortal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textLabel.text = str(coinRequired)



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if body.coinNumber >= coinRequired:
			#print("The Player has reached the portal.")
			emit_signal("playerReachedThePortal")
