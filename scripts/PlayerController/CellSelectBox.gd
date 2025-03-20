class_name CellSelectBox
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.z_index = 100
	sprite.visible = false