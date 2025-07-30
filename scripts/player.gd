class_name Player
extends CharacterBody2D

@export var baseSpeed := 300.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = baseSpeed * direction
	move_and_slide()
