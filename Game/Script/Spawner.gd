extends Node3D

var spawnPoints : Array[Node]
var enemyNodes : Array[Node]
var hasSpawned : bool
var gate : Node3D
var levelIsFinished : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnPoints = get_node("SpawnPoints").get_children()
	gate = get_node("Gate")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if enemyNodes.is_empty() || levelIsFinished:
		return
	
	for enemy in enemyNodes:
		if enemy != null:
			return
			
	levelIsFinished = true
	gate.open()



func _on_spawn_trigger_zone_body_entered(body: Node3D) -> void:
	if hasSpawned:
		return
	
	if body.is_in_group("Player"):
		Spawn()
		
		
func Spawn():
	for point in spawnPoints:
		SpawnEnemyAt(point)
		
	hasSpawned = true
	
func SpawnEnemyAt(targetPoint : Node):
	var enemyToSpawn = preload("res://Game/Scene/Enemy.tscn")
	var enemyInstance = enemyToSpawn.instantiate()
	get_tree().get_root().get_node("Node3D").add_child(enemyInstance)
	enemyInstance.global_position = targetPoint.global_position
	
	enemyNodes.append(enemyInstance)
