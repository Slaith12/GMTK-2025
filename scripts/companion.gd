class_name Companion
extends Area2D

@export var influenceStrength := 5000.0
@export var targetRadius := 150.0
@export var redirectCoef := 0.2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var projInfluence: ProjectileInfluence = $ProjectileInfluencer
@onready var minRadius = $CollisionShape2D.shape.radius

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

func influence_projectiles(delta: float) -> void:
	for i in influencedProjectiles.size():
		var proj := influencedProjectiles[i]
		var velocity := proj.velocity
		var offset := position - proj.position
		var congruency := offset.normalized().dot(velocity.normalized())
		#if positive, projectile is going counter-clockwise, use (-y, x) to point towards self
		var perp := offset.normalized().cross(velocity.normalized())
		var pullVector := offset.normalized()
		var redirectVector := Vector2(velocity.y, -velocity.x).normalized()
		if perp < 0:
			redirectVector *= -1
		
		var closeness := inverse_lerp(lerpf(minRadius, targetRadius, redirectCoef), targetRadius, offset.length())
		var comb := clampf(lerpf(0, 1, closeness), 0, 1)
		var forceVector := redirectVector.lerp(pullVector, comb) * influenceStrength
		
		print("Closeness: ", closeness,
			" Ratio: ", comb,
			" Force vector: ", forceVector)
		
		proj.velocity += forceVector * delta / proj.mass

func activate() -> void:
	if activated or isStunned:
		return
	projInfluence.show()
	projInfluence.process_mode = Node.PROCESS_MODE_INHERIT
	activated = true
	influence_activate.emit(projInfluence)


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


func stun(stunner: Node2D) -> void:
	return
	isStunned = true
	deactivate()
	stunned.emit(stunner)
	animation_player.play("Stun")


func unstun() -> void:
	if not isStunned:
		return
	isStunned = false
	unstunned.emit()


func _on_projectile_influencer_body_entered(body: Node2D) -> void:
	print("Entered")
	influencedProjectiles.append(body)


func _on_projectile_influencer_body_exited(body: Node2D) -> void:
	print("Exited")
	influencedProjectiles.erase(body)


func _on_hitbox_entered(node: Node2D) -> void:
	if node.is_in_group("PlayerDamaging"):
		stun(node)
