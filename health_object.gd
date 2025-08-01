class_name HealthObject
extends Area2D

@onready var health_bar: Polygon2D = $HealthBar
@onready var health_display: Polygon2D = $HealthBar/HealthDisplay

@export var maxHealth := 33
@export var currentHealth : int
@export var regenDelay := 1.75
@export var regenTickDelay := 0.04
@export var ignoreDamage := false

var regenTimer := 0.0
var tempTickDelay := 0.0

signal damaged(damager: Node2D, amount: int)
signal killed(damager: Node2D, amount: int)

func _ready() -> void:
	currentHealth = maxHealth
	health_bar.hide()

func _process(delta: float) -> void:
	if currentHealth < maxHealth:
		regenTimer -= delta
		while regenTimer <= 0 and currentHealth < maxHealth:
			currentHealth += 1
			if tempTickDelay > 0:
				regenTimer += tempTickDelay
			else:
				regenTimer += regenTickDelay
	if currentHealth >= maxHealth:
		health_bar.hide()
	else:
		health_bar.show()
		health_display.scale = Vector2(clampf(float(currentHealth) / maxHealth, 0, 1), 1)


func disable_regen():
	regenTimer = 10000
	
func quick_regen(time : float, percent := 1):
	tempTickDelay = time / maxHealth * percent
	regenTimer = tempTickDelay

func damage(damager: Node2D, amount: int):
	if ignoreDamage:
		return
	currentHealth -= amount
	regenTimer = regenDelay
	tempTickDelay = 0
	damaged.emit(damager, amount)
	if currentHealth <= 0:
		killed.emit(damager, amount)
	
