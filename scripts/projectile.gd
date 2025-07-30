class_name Projectile
extends AnimatableBody2D

@export var mass := 1.0
@export var pierces := 1

var velocity : Vector2

func _physics_process(delta: float) -> void:
	translate(velocity * delta)
