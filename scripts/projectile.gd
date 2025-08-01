class_name Projectile
extends Area2D

@export var mass := 1.0
@export var pierces := 1
@export var damage := 10
@export var waitTime := 0.1

var velocity : Vector2
var activeTime := 0.0

func _physics_process(delta: float) -> void:
	activeTime += delta
	translate(velocity * delta)


func _on_area_entered(area: Area2D) -> void:
	print("area entered")
	if area is HealthObject and pierces > 0:
		var health : HealthObject = area
		if health.ignoreDamage:
			return
		print("damaging")
		health.damage(self, damage)
		pierces -= 1
		if pierces == 0:
			queue_free()
