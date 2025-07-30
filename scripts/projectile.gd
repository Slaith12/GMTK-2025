class_name Projectile
extends AnimatableBody2D

static var influences : Array[ProjectileInfluence] = []

@export var mass := 1.0
@export var correctionCoefficient := 10.0
@export var target_velocity := 1000.0
@export var pierces := 1

@export var velocity : Vector2

func _physics_process(delta: float) -> void:
	apply_influences(delta)
	translate(velocity * delta)
	
	var correctionStrength = (target_velocity - velocity.length()) * correctionCoefficient * delta
	
	velocity += velocity.normalized() * correctionStrength

func apply_influences(delta : float) -> void:
	#print("Start influence check")
	for inf in influences:
		var distance = inf.sourcePoint.distance_to(global_position)
		#print("Checking. Distance: " + str(distance))
		if distance > inf.outerRadius:
			continue
		
		var direction := (inf.sourcePoint - global_position).normalized()
		var weight := clampf((distance - inf.innerRadius)/(inf.outerRadius - inf.innerRadius), 0.0, 1.0)
		var strength := lerpf(inf.maxStrength, inf.minStrength, weight)
		
		print("Applying influence. Direction: ", direction, 
		" Strength: ", strength, " (Weight: ", weight, ")",
		" Force Vector: ", direction * strength,
		" Delta: ", delta,
		" Mass: ", mass,
		" Pure Vector: ", direction * strength * delta / mass)
		
		print("Current Velocity: ", velocity)
		velocity += direction * strength * delta / mass
		print("New Velocity: ", velocity)
