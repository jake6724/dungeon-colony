class_name Plant
extends Node2D

@onready var sprite = $Sprite2D
var cname = ""
var inspector_name = ""
var is_tree: bool = false

func _init():
	set_data()

func set_data() -> void:
	pass