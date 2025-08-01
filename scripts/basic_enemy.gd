class_name BasicEnemy
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var secondary_anims: AnimationPlayer = $AnimationPlayer2
@onready var health_object: HealthObject = $HealthObject
@onready var fire_pos: Marker2D = $FirePos

@export var attackCooldown := 2.5
@export var deathKnockback := 200.0
@export var fireSpacing := 90
@export var acceleration := 300.0

@export var targetVelocity : Vector2

var isDead := false

signal died(source: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var accelStrength := acceleration * delta
	var accelDir := targetVelocity - velocity
	if accelDir.length() < accelStrength:
		velocity = targetVelocity
	else:
		velocity += accelDir.normalized() * accelStrength
		
	move_and_slide()
	
func fire(direction: Vector2, projectile: Missile):
	fire_pos.position = direction.normalized() * fireSpacing
	projectile.global_position = fire_pos.global_position
	projectile.velocity = direction * projectile.target_velocity

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
