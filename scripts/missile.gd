class_name Missile
extends Projectile

@export var correctionCoefficient := 5.0
@export var target_velocity := 1000.0

func _physics_process(delta: float) -> void:
	super(delta)
	
	var correctionStrength = (target_velocity - velocity.length()) * correctionCoefficient * delta
	
	velocity += velocity.normalized() * correctionStrength
