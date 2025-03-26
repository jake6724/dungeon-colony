class_name Buff
extends Resource

var name: String = "None"

var attack_speed: float
var movement_speed: float
var damage_resistance: float 
var damage_multiplier: float

func _init(_attack_speed:float = 0, _movement_speed: float= 0, _damage_resistance:float = 0, _damage_multiplier:float = 0):
	attack_speed = _attack_speed
	movement_speed = _movement_speed
	damage_resistance = _damage_resistance
	damage_multiplier = _damage_multiplier