class_name Plant
extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var plant_name: String = ""

func _init():
	set_data()

func set_data() -> void:
	pass
