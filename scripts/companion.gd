class_name Companion
extends Node2D

@export var influenceStrength := 5000.0
@export var targetRadius := 150.0
@export var redirectCoef := 0.2
@export var targetPos : Vector2
@export var lerpCoef := 0.2
@export var lerpSnapRange := 2.0
@export var knockbackDistance := 200.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var secondary_anims: AnimationPlayer = $AnimationPlayer2
@onready var projInfluence: ProjectileInfluence = $ProjectileInfluencer
@onready var health_object: HealthObject = $HealthObject
@onready var minRadius = $HealthObject/CollisionShape2D.shape.radius

signal influence_activate(influence : ProjectileInfluence)
signal influence_deactivate(influence : ProjectileInfluence)
signal stunned(stunner: Node2D)
signal unstunned()

var influencedProjectiles : Array[Projectile] = []
var influenceBeams : Array[Line2D] = []
var isStunned : bool
var activated : bool

func _ready() -> void:
	isStunned = false
	deactivate()


func _physics_process(delta: float) -> void:
	if activated:
		influence_projectiles(delta)
	
	position = position.lerp(targetPos, lerpCoef)
	if position.distance_to(targetPos) < lerpSnapRange:
		position = targetPos

func influence_projectiles(delta: float) -> void:
	for i in influencedProjectiles.size():
		var proj := influencedProjectiles[i]
		if proj.activeTime < proj.waitTime:
			continue
		var velocity := proj.velocity
		var offset := global_position - proj.global_position
		var congruency := offset.normalized().dot(velocity.normalized())
		#if positive, projectile is going clockwise, use (y, -x) to point towards self
		var perp := offset.normalized().cross(velocity.normalized())
		var pullVector := offset.normalized()
		var redirectVector := Vector2(velocity.y, -velocity.x).normalized()
		if perp > 0:
			redirectVector *= -1
		
		var closeness := inverse_lerp(lerpf(minRadius, targetRadius, redirectCoef), targetRadius, offset.length())
		var comb := clampf(closeness, 0, 1)
		var forceVector := (redirectVector * congruency).lerp(pullVector * abs(perp), comb) * influenceStrength
		
		#print("Velocity: ", velocity,
			#" Offset: ", offset,
			#" Congruency: ", congruency,
			#" Perp: ", perp)
		#print("Pull: ", pullVector,
			#" Redirect: ", redirectVector)
		#print("Closeness: ", closeness,
			#" Ratio: ", comb,
			#" Force vector: ", forceVector)
		
		proj.velocity += forceVector * delta / proj.mass
		#print(velocity.length())

func activate() -> void:
	if activated or isStunned:
		return
	projInfluence.show()
	projInfluence.process_mode = Node.PROCESS_MODE_INHERIT
	activated = true
	influence_activate.emit(projInfluence)
	animation_player.clear_queue()
	animation_player.play("Attracting")


func deactivate() -> void:
	if not activated:
		return
	projInfluence.hide()
	projInfluence.process_mode = Node.PROCESS_MODE_DISABLED
	activated = false
	influence_deactivate.emit(projInfluence)
	influencedProjectiles.clear()
	for beam in influenceBeams:
		beam.hide()
	animation_player.play("RESET")


func hurt() -> void:
	if secondary_anims.current_animation == "Hurt":
		secondary_anims.stop(true)
	secondary_anims.play("Hurt")

func stun(stunner: Node2D, _damage: int) -> void:
	isStunned = true
	health_object.ignoreDamage = true
	health_object.regenTimer = 100
	deactivate()
	targetPos = position + (global_position - stunner.global_position).normalized() * knockbackDistance
	animation_player.clear_queue()
	animation_player.play("Stun")
	secondary_anims.play("Recovery")
	stunned.emit(stunner)


func unstun() -> void:
	if not isStunned:
		return
	isStunned = false
	health_object.ignoreDamage = false
	unstunned.emit()


func _on_projectile_influencer_body_entered(body: Node2D) -> void:
	print("Entered")
	influencedProjectiles.append(body)


func _on_projectile_influencer_body_exited(body: Node2D) -> void:
	print("Exited")
	influencedProjectiles.erase(body)
