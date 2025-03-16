extends Node2D

@onready var lm: Overworld = $Overworld
@onready var pf: PathFinder = $Overworld/PathFinding
@onready var camera: Camera2D = $Camera2D
var game_started: bool = false

func _ready():
	center_camera()
	lm.initialize_overworld()
	pf.initialize()

func center_camera() -> void:
	camera.position = get_viewport().size / 2

# func _input(event):
# 	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
# 		if event.pressed:
# 			var clicked = lm.worldToGrid(get_global_mouse_position())
# 			lm.grid[clicked].navigable = false
# 			lm.grid[clicked].floor_data = preload("res://data/floor/grass.tres")
# 			lm.refreshCellFloor(clicked)


# 			var rect = ReferenceRect.new()
# 			rect.position = grid.gridToWorld(clicked)
# 			rect.size = Vector2(grid.cell_size, grid.cell_size)
# 			rect.editor_only = false
# 			rect.border_color = Color.ORANGE
# 			grid.debug.add_child(rect)
