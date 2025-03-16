class_name Mineral
extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var mineral_name: String = ""
var vein_growth: float = 0
var vein_growth_reduction: float = 0

func _init():
	set_data()

# func _ready():
# 	set_data()

func set_data() -> void:
	pass
