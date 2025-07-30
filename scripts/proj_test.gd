extends Node2D

@onready var influence_display: Sprite2D = $InfluenceDisplay
@onready var inner_display: Sprite2D = $InnerDisplay
@onready var player: Player = $Player
@onready var spawner: Sprite2D = $Spawner
@onready var missile: Projectile = $Missile

@export var projSpeed := 400.0

func _ready() -> void:
	influence_display.hide()
	inner_display.hide()
	
func _process(_delta: float) -> void:
	influence_display.position = player.projInfluence.sourcePoint
	inner_display.position = player.projInfluence.sourcePoint
	influence_display.scale = Vector2.ONE * player.influenceOuterRadius / influence_display.texture.get_size()
	inner_display.scale = Vector2.ONE * player.influenceInnerRadius / inner_display.texture.get_size()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("secondary_action"):
		var instance : Projectile = missile.duplicate()
		instance.velocity = spawner.position.direction_to(player.position) * projSpeed
		instance.position = spawner.position
		instance.process_mode = Node.PROCESS_MODE_INHERIT
		instance.show()
		add_child(instance)

func _on_player_influence_activate(influence: ProjectileInfluence) -> void:
	influence_display.show()
	inner_display.show()

func _on_player_influence_deactivate(influence: ProjectileInfluence) -> void:
	influence_display.hide()
	inner_display.hide()
