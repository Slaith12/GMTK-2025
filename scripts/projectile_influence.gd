class_name ProjectileInfluence
extends RefCounted

## The point that the projectile is drawn towards (or away from)
var sourcePoint : Vector2
## The max strength of the influence. If negative, the projectile is pushed away from the influence.
var maxStrength : float
## The minimum strength of the influence. If negative, the projectile is pushed away from the influence.
var minStrength : float
## Any projectile within this radius is affected by the full strength.
## Outside this radius, strength will decrease linearlly to minStrength at the outer radius.
var innerRadius : float
## Any projectile outside this radius is not affected by the influence.
var outerRadius : float

func _init(sourcePoint : Vector2, maxStrength : float, outerRadius : float, minStrength := 0, innerRadius := 0) -> void:
	self.sourcePoint = sourcePoint
	self.maxStrength = maxStrength
	self.minStrength = minStrength
	self.innerRadius = innerRadius
	self.outerRadius = outerRadius
