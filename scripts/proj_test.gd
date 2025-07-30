extends Node2D

@onready var influence_display: Sprite2D = $Companion/InfluenceDisplay
@onready var inner_display: Sprite2D = $Companion/InnerDisplay
@onready var player: Player = $Player
@onready var spawner: Sprite2D = $Spawner
@onready var missile: Projectile = $Missile
@onready var companion: Companion = $Companion
@onready var companion_influence_shape: CollisionShape2D = $Companion/ProjectileInfluencer/CollisionShape2D

@export var projSpeed := 400.0

func _ready() -> void:
	influence_display.hide()
	inner_display.hide()
	
func _process(_delta: float) -> void:
	influence_display.scale = Vector2.ONE * 2 * companion_influence_shape.shape.radius / influence_display.texture.get_size()
	inner_display.scale = Vector2.ONE * 2 * companion.targetRadius / inner_display.texture.get_size()
	companion.position = get_local_mouse_position()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("secondary_action"):
		var instance : Projectile = missile.duplicate()
		instance.velocity = spawner.position.direction_to(player.position) * projSpeed
		instance.position = spawner.position
		instance.process_mode = Node.PROCESS_MODE_INHERIT
		instance.show()
		add_child(instance)
	elif event.is_action_pressed("primary_action"):
		companion.activate()
	elif event.is_action_released("primary_action"):
		companion.deactivate()

func _on_player_influence_activate(_influence: ProjectileInfluence) -> void:
	influence_display.show()
	inner_display.show()

func _on_player_influence_deactivate(_influence: ProjectileInfluence) -> void:
	influence_display.hide()
	inner_display.hide()
