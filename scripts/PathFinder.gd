class_name PathFinder
extends Node

# Make untis move through the center of the point not top right ? 

var a_star = AStar2D.new()
@onready var main = get_tree().root.get_node("Main")
@onready var ow = main.get_node("Overworld")

const DIRECTIONS: Array[Vector2] = [(Vector2.UP + Vector2.LEFT), Vector2.UP, (Vector2.UP + Vector2.RIGHT), 
Vector2.LEFT, Vector2.RIGHT, (Vector2.DOWN + Vector2.LEFT), Vector2.DOWN, (Vector2.DOWN + Vector2.RIGHT)]

func initialize():
	addAllPoints()
	connectAllPoints()

func getPath(_point_a: Vector2, _point_b: Vector2) -> PackedVector2Array:
	var a_id: int = getPointID(_point_a)
	var b_id: int = getPointID(_point_b)
	var a_star_path: PackedVector2Array = a_star.get_point_path(a_id, b_id, true)
	return a_star_path

## Configure AStar node with all overworld grid points. AStar stores this as id + Vector2 position and uses points to determine
## pathing
func addAllPoints():
	var cur_id = 0
	for point in ow.grid:
		a_star.add_point(cur_id, ow.gridToWorld(point))
		cur_id += 1

## Iterate over all overworld grid points and run connectPoint on them. Used to connect all points to eachother in overworld.
func connectAllPoints():
	for point in ow.grid:
		connectPoint(point)
		ow.grid[point].navChanged.connect(onNavChanged) 

func connectPoint(_point: Vector2) -> void:
	var _point_id = getPointID(_point)
	# Don't connect a point to its neighbors if it isn't navigable itself
	# This will save time by not processing mountain tiles
	if not(ow.grid[_point].is_navigable):
		return 
		
	for direction in DIRECTIONS:
		var neighbor = _point + direction
		var neighbor_id = getPointID(neighbor)

		if ow.grid.has(neighbor) and ow.grid[neighbor].is_navigable:
			a_star.connect_points(_point_id, neighbor_id)

## Disconnect point from all of its neighbors. Requires grid_point
func disconnectPoint(grid_point: Vector2) -> void:
	var _point_id = getPointID(grid_point)
	for direction in DIRECTIONS:
		var neighbor = grid_point + direction
		var neighbor_id = getPointID(neighbor)
		a_star.disconnect_points(_point_id, neighbor_id)

func onNavChanged(_pos: Vector2) -> void:
	if ow.grid[_pos].is_navigable:
		connectPoint(_pos)
	else:
		disconnectPoint(_pos)

## Takes grid point and returns AStar point ID. Requires grid point, not world point.
func getPointID(grid_point: Vector2) -> int:
	return a_star.get_closest_point(ow.gridToWorld(grid_point))

func getWorldID(world_point: Vector2) -> int:
	return a_star.get_closest_point(world_point)

func getIDWorldPos(_id: int) -> Vector2:
	return a_star.get_point_position(_id)

func getIDGridPos(_id: int) -> Vector2:
	var worldPos = getIDWorldPos(_id)
	return ow.worldToGrid(worldPos)
