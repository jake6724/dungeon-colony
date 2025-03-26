extends Node2D

@onready var ow: Overworld = $Overworld
@onready var pf: PathFinder = $Overworld/PathFinding
@onready var camera: Camera2D = $Camera2D
@onready var player_units: Node = $PlayerUnits
var game_started: bool = false

@onready var player_unit = preload("res://scenes/player_unit.tscn")

func _ready():
	center_camera()
	ow.initialize_overworld()
	pf.initialize()


func _input(_event):
	if Input.is_action_pressed("spawn_unit") and Input.is_action_just_pressed("left_click"):
		spawn_player_unit()

func center_camera() -> void:
	camera.position = get_viewport().size / 2


func spawn_player_unit() -> void: 
	var spawn_position_world = get_global_mouse_position()
	var spawn_position_grid = ow.worldToGrid(spawn_position_world)

	var new_player_unit: PlayerUnit = player_unit.instantiate()
	new_player_unit.position = ow.gridToWorld(spawn_position_grid)
	player_units.add_child(new_player_unit)
