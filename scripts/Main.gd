extends Node2D

@onready var grid = $Grid
@onready var pf = $Grid/Pathfinding

func _ready():
	# grid.generateGrid()
	pf.initialize()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			var clicked = grid.worldToGrid(get_global_mouse_position())
			grid.grid[clicked].navigable = false
			grid.grid[clicked].floor_data = preload("res://data/floor/grass.tres")
			grid.refreshTile(clicked)


# 			var rect = ReferenceRect.new()
# 			rect.position = grid.gridToWorld(clicked)
# 			rect.size = Vector2(grid.cell_size, grid.cell_size)
# 			rect.editor_only = false
# 			rect.border_color = Color.ORANGE
# 			grid.debug.add_child(rect)
