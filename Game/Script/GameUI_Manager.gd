extends Control

@onready var coinLabel:Label = $HBoxContainer_Coin/Label_Coin
@onready var healthBar : ProgressBar = $HBoxContainer_Health/ProgressBar

@export var player:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.coinNumberUpdated.connect(UpdateCoinLabel)
	player.playerHealthUpdated.connect(UpdateHealthBar)
	
	UpdateHealthBar(player.currentHealth, player.maxHealth)

func UpdateCoinLabel(newValue:int):
	coinLabel.text = str(newValue)

func UpdateHealthBar(newValue : int, maxValue : int):
	var value = float(newValue) / float(maxValue) * 100
	healthBar.value = int(value)
