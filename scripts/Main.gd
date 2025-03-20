extends Node2D

@onready var ow: Overworld = $Overworld
@onready var pf: PathFinder = $Overworld/PathFinding
@onready var camera: Camera2D = $Camera2D
var game_started: bool = false

func _ready():
	center_camera()
	ow.initialize_overworld()
	pf.initialize()


# func _input(_event):
# 	if not game_started:
# 		if Input.is_action_just_pressed("start_game"):
# 			game_started = true
# 			center_camera()
# 			ow.initialize_overworld()
# 			pf.initialize()

func center_camera() -> void:
	camera.position = get_viewport().size / 2
