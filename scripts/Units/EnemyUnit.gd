class_name EnemyUnit
extends Node2D

@onready var area = $UnitArea

func _ready():
	area.collision_layer = Constants.layer_mapping["enemy_unit"]
