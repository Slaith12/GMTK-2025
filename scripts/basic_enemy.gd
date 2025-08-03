class_name BasicEnemy
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var secondary_anims: AnimationPlayer = $AnimationPlayer2
@onready var health_object: HealthObject = $HealthObject
@onready var fire_pos: Marker2D = $FirePos
@onready var player: Player = %Player
@onready var companion: Companion = %Companion

@export var rootNode : Node2D

@export var attackCooldown := 3
@export var moveCooldown := 1.5
@export var moveSearchRange := 150.0
@export var innerRange := 300.0
@export var outerRange := 400.0
@export var deathKnockback := 200.0
@export var walkMoveSpeed := 100.0
@export var acceleration := 300.0

@export var fireSpacing := 90
@export var targetVelocity : Vector2

enum {MOVE, ATTACK, NONE}
var state := MOVE
var isDead := false

var movesLeft : int
var moveTimer : float

var attackTimer : float
var attacksLeft : int
var attackAngle : float
var attackSpread : float
var attackDelay : float
var currentProjectile : PackedScene

signal died(source: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_movement()

func _physics_process(delta: float) -> void:
	update_logic(delta)
	var accelStrength := acceleration * delta
	var accelDir := targetVelocity - velocity
	if accelDir.length() < accelStrength:
		velocity = targetVelocity
	else:
		velocity += accelDir.normalized() * accelStrength
		
	move_and_slide()
	
func update_logic(delta: float) -> void:
	match state:
		MOVE:
			moveTimer -= delta
			if moveTimer <= 0:
				if movesLeft < 0:
					pause()
					targetVelocity = Vector2.ZERO
					animation_player.play("Attack")
				else:
					var targetPoint := Vector2.from_angle(randf() * TAU) * moveSearchRange + position
					var targetOffset := (targetPoint - player.position)
					if targetOffset.length() < innerRange:
						targetPoint = player.position + targetOffset.normalized() * innerRange
					elif targetOffset.length() > outerRange:
						targetPoint = player.position + targetOffset.normalized() * outerRange
					#targetOffset variable not updated since it's not needed
					targetVelocity = (targetPoint - position).normalized() * walkMoveSpeed
					moveTimer += moveCooldown
					movesLeft -= 1
		ATTACK:
			attackTimer -= delta
			while attackTimer <= 0 and attacksLeft > 0:
				attackTimer += attackDelay
				var fireDirection := Vector2.from_angle(attackAngle)
				var proj = currentProjectile.instantiate()
				rootNode.add_child(proj)
				fire(fireDirection, proj)
				attackAngle += attackSpread
				attacksLeft -= 1
			
func start_movement() -> void:
	movesLeft = attackCooldown
	moveTimer = 0
	state = MOVE
	

func pause() -> void:
	state = NONE

func fire(direction: Vector2, projectile: Missile):
	fire_pos.position = direction.normalized() * fireSpacing
	projectile.global_position = fire_pos.global_position
	projectile.velocity = direction * projectile.target_velocity


func fire_flurry(spread: float, time: float, num: int, proj: PackedScene):
	var baseAngle := global_position.angle_to_point(player.global_position)
	attackAngle = baseAngle - spread/2
	attackSpread = spread/(num-1)
	attackTimer = 0
	attackDelay = time/(num-1)
	attacksLeft = num
	currentProjectile = proj
	state = ATTACK

func hurt() -> void:
	if secondary_anims.current_animation == "Hit":
		secondary_anims.stop(true)
	secondary_anims.play("Hit")

func kill(killer: Node2D) -> void:
	isDead = true
	health_object.ignoreDamage = true
	health_object.regenTimer = 100
	velocity = (global_position - killer.global_position).normalized() * deathKnockback
	targetVelocity = Vector2.ZERO
	animation_player.clear_queue()
	animation_player.play("Death")
	died.emit(killer)
