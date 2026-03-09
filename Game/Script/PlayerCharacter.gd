extends CharacterBody3D

@onready var visual : Node3D = $VisualNode
@onready var animationPlayer: AnimationPlayer = $VisualNode/AnimationPlayer

@onready var footStepVFX: GPUParticles3D = $VisualNode/VFX/Footstep_GPUParticles3D

var direction : Vector3
var slideKey_pressed : bool
var attackKey_pressed : bool

var maxHealth : int = 100
var currentHealth : int:
	set(new_value):
		currentHealth = new_value
		emit_signal("playerHealthUpdated", currentHealth, maxHealth)


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var coinNumber: int:
	set(new_value):
		coinNumber = new_value
		emit_signal("coinNumberUpdated",coinNumber)

signal coinNumberUpdated(newValue)
signal playerHealthUpdated(newValue, maxValue)

func _ready():
	currentHealth = maxHealth


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	slideKey_pressed = Input.is_action_just_pressed("Slide")
	attackKey_pressed = Input.is_action_just_pressed("Attack")

	move_and_slide()

func AddCoin(value:int):
	coinNumber += value
	print(coinNumber)


func takeDamage(damage: int, enemy_position : Vector3):
	currentHealth -= damage
	currentHealth = clamp(currentHealth, 0, maxHealth)
	print("The Player took damage :", damage, "current health :", currentHealth)
	
	get_node("StateMachine").switchTo("Hurt")
	
	if get_node("StateMachine").currentState.name == "Hurt":
		get_node("StateMachine").currentState.pushBackDir = (global_position - enemy_position).normalized()


func AddHealth(value: int):
	currentHealth += value
	currentHealth = clamp(currentHealth, 0, maxHealth)
	
	
