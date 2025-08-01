class_name Player
extends CharacterBody2D

@onready var health_object: HealthObject = $HealthObject
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var secondary_anims: AnimationPlayer = $AnimationPlayer2
@onready var sprite: Sprite2D = $Sprite2D

@export_group("Basic Stats")
@export var baseSpeed := 300.0
@export var knockbackForce := 200.0

@export_group("Force Move")
@export var forceVelocity : Vector2
@export var isForceMoving := false

func _physics_process(_delta: float) -> void:
	if isForceMoving:
		velocity = forceVelocity
	else:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = baseSpeed * direction
		if velocity != Vector2.ZERO:
			animation_player.play("Walk")
		elif animation_player.current_animation == "Walk":
			animation_player.play("Idle")
		
	if velocity.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	move_and_slide()
	

func hit() -> void:
	if secondary_anims.current_animation == "Hit":
		secondary_anims.stop(true)
	secondary_anims.play("Hit")
	
func damage(damager: Node2D) -> void:
	isForceMoving = true
	forceVelocity = (global_position - damager.global_position).normalized() * knockbackForce
	animation_player.play("Hurt")
	secondary_anims.play("Recovery")
