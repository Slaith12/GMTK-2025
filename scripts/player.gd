class_name Player
extends CharacterBody2D

#region Exported variables
@export var baseSpeed := 300.0
@export var influenceMaxStrength := 100.0:
	set(value):
		projInfluence.maxStrength = value
		influenceMaxStrength = value
@export var influenceMinStrength := 10.0:
	set(value):
		projInfluence.minStrength = value
		influenceMinStrength = value
@export var influenceInnerRadius := 10.0:
	set(value):
		projInfluence.innerRadius = value
		influenceInnerRadius = value
@export var influenceOuterRadius := 100.0:
	set(value):
		projInfluence.outerRadius = value
		influenceOuterRadius = value
#endregion

signal influence_activate(influence : ProjectileInfluence)
signal influence_deactivate(influence : ProjectileInfluence)

var projInfluence : ProjectileInfluence:
	get:
		if projInfluence == null:
			projInfluence = ProjectileInfluence.new(Vector2.ZERO, influenceMaxStrength,
	 		  influenceOuterRadius, influenceMinStrength, influenceInnerRadius)
		return projInfluence

var influencing : bool

func _ready() -> void:
	influencing = false

func _process(delta: float) -> void:
	projInfluence.sourcePoint = get_global_mouse_position()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_action"):
		Projectile.influences.append(projInfluence)
		influencing = true
		influence_activate.emit(projInfluence)
	elif event.is_action_released("primary_action"):
		Projectile.influences.erase(projInfluence)
		influencing = false
		influence_deactivate.emit(projInfluence)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = baseSpeed * direction
	move_and_slide()
