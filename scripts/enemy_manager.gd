@tool
class_name EnemyManager
extends Node2D

@export var player: Player
@export var companion: Companion
@export var baseEnemyPointsNode: Node2D
@export var enemyPoints: Array[Node2D]
@export var numEnemyPoints := 7
@export var enemyPointRadius := 400.0
@export var update_config := false

var claimedPoints: Array[bool]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	claimedPoints = []
	claimedPoints.resize(enemyPoints.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if update_config:
		update_enemy_points_config()
		update_config = false

func update_enemy_points_config() -> void:
	if enemyPoints == null:
		enemyPoints = []
	enemyPoints.resize(numEnemyPoints)
	if not Engine.is_editor_hint():
		claimedPoints.resize(numEnemyPoints)
	var spacing = TAU/numEnemyPoints
	for i in range(numEnemyPoints):
		if enemyPoints[i] == null:
			enemyPoints[i] = Marker2D.new()
			baseEnemyPointsNode.add_child(enemyPoints[i])
			enemyPoints[i].owner = self.owner
		enemyPoints[i].position = Vector2(cos(spacing*i), sin(spacing*i)) * enemyPointRadius
	
