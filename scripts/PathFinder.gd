class_name PathFinder
extends Node

var a_star = AStar2D.new()
@onready var main = get_tree().root.get_node("Main")
@onready var grid: Grid = main.get_node("Grid")



const DIRECTIONS = [Vector2.UP, (Vector2.UP + Vector2.LEFT), (Vector2.UP + Vector2.RIGHT), 
	Vector2.DOWN, (Vector2.DOWN + Vector2.LEFT), (Vector2.DOWN + Vector2.RIGHT),
	Vector2.LEFT, Vector2.RIGHT]

func initialize():
	addPoints()
	connectAllPoints()

func getPath(_point_a: Vector2, _point_b: Vector2) -> PackedVector2Array:
	var a_id: int = getPointID(_point_a)
	var b_id: int = getPointID(_point_b)
	var a_star_path: PackedVector2Array = a_star.get_point_path(a_id, b_id)
	return a_star_path

func addPoints():
	var cur_id = 0
	for point in grid.grid:
		a_star.add_point(cur_id, grid.gridToWorld(point))
		cur_id += 1

func connectAllPoints():
	for point in grid.grid:
		connectPoint(point)

		# Connect to navChanged signal. This is found in the grid point's CellData
		# The signal includes the arguments needed by this function and passes them somehow...
		grid.grid[point].navChanged.connect(onNavChanged) 

func connectPoint(_point: Vector2) -> void:
	var _point_id = getPointID(_point)
	for direction in DIRECTIONS:
		var neighbor = _point + direction
		var neighbor_id = getPointID(neighbor)

		if grid.grid.has(neighbor) and grid.grid[neighbor].navigable:
			a_star.connect_points(_point_id, neighbor_id)

## Disconnect point from all of its neighbors. Requires grid_point
func disconnectPoint(grid_point: Vector2) -> void:
	var _point_id = getPointID(grid_point)
	for direction in DIRECTIONS:
		var neighbor = grid_point + direction
		var neighbor_id = getPointID(neighbor)
		a_star.disconnect_points(_point_id, neighbor_id)

func onNavChanged(_pos: Vector2) -> void:
	if grid.grid[_pos].navigable:
		connectPoint(_pos)
	else:
		disconnectPoint(_pos)

## Takes grid point and returns AStar point ID. Requires grid point, not world point.
func getPointID(grid_point: Vector2) -> int:
	return a_star.get_closest_point(grid.gridToWorld(grid_point))

func getWorldID(world_point: Vector2) -> int:
	return a_star.get_closest_point(world_point)

func getIDWorldPos(_id: int) -> Vector2:
	return a_star.get_point_position(_id)

func getIDGridPos(_id: int) -> Vector2:
	var worldPos = getIDWorldPos(_id)
	return grid.worldToGrid(worldPos)
