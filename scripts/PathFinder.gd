class_name PathFinder
extends Node

@onready var main = get_tree().root.get_node("Main")
@onready var ow = main.get_node("Overworld")
var a_star = AStar2D.new()
var grid_point_id_map: Dictionary[Vector2, int] = {} # Store the Astar ID mapping of each grid point

func initialize():
	add_all_points()
	connect_all_points()

func get_astar_path(point_a: Vector2, point_b: Vector2) -> PackedVector2Array:
	# Both param points are grid points
	if ow.grid.has(point_b):
		# Find a new nearby and unreserved destination grid point if point_b is reserved
		if ow.grid[point_b].is_reserved or (not ow.grid[point_b].is_navigable):
			point_b = find_valid_point(point_b)

		if not ow.grid[point_a].is_navigable:
			point_a = find_valid_point(point_a)

		# ID's are Astar node internal id's
		# TODO:
		var a_id: int = get_grid_point_id(point_a)
		var b_id: int = get_grid_point_id(point_b)
		var a_star_path: PackedVector2Array = a_star.get_point_path(a_id, b_id, false)

		return a_star_path

	# If the target point doesn't exist, return an empty path
	return PackedVector2Array()

## Configure AStar node with all overworld grid points. AStar stores this as id + Vector2 position and uses points to determine
## pathing
func add_all_points():
	var cur_id = 0
	for grid_point in ow.grid:
		a_star.add_point(cur_id, ow.gridToWorld(grid_point))
		grid_point_id_map[grid_point] = cur_id # Save all point mappings for O(1) look-up in the future
		cur_id += 1

## Iterate over all overworld grid points and run connect_point on them. Used to connect all points to eachother in overworld.
func connect_all_points():
	for point in ow.grid:
		connect_point(point)
		ow.grid[point].nav_changed.connect(on_nav_changed) 

func connect_point(grid_point: Vector2) -> void:
	var grid_point_id = grid_point_id_map.get(grid_point, -1)

	# Don't connect a point to its neighbors if it isn't navigable itself
	# This will save time by not processing mountain tiles
	if grid_point_id == -1 or not ow.grid[grid_point].is_navigable :
		return 
		
	for direction in Constants.DIRECTIONS:
		var neighbor: Vector2 = grid_point + direction
		var neighbor_id = grid_point_id_map.get(neighbor, -1)

		if neighbor_id != -1 and ow.grid[neighbor].is_navigable:
				a_star.connect_points(grid_point_id, neighbor_id)

## Disconnect point from all of its neighbors. Requires grid_point
func disconnect_point(grid_point: Vector2) -> void:
	var grid_point_id = grid_point_id_map[grid_point]
	for direction in Constants.DIRECTIONS:
		var neighbor = grid_point + direction
		var neighbor_id = grid_point_id_map[neighbor]
		a_star.disconnect_points(grid_point_id, neighbor_id)

func on_nav_changed(grid_point: Vector2) -> void:
	if ow.grid[grid_point].is_navigable:
		connect_point(grid_point)
	else:
		disconnect_point(grid_point)

func find_valid_point(grid_point: Vector2) -> Vector2:
	var queue = [grid_point]
	var visited = {grid_point: true} # Keep as an array for O(1) look up time

	while queue.size() > 0:
		var current_point = queue.pop_front()

		# Return this point if unreserved, and mark as reserved
		if not ow.grid[current_point].is_reserved and ow.grid[current_point].is_navigable:
			visited.erase(current_point)
			return current_point

		visited[current_point] = true

		for direction in Constants.ORTHOGONAL_DIRECTIONS:
			var neighbor = current_point + direction
			if ow.grid.has(neighbor) and neighbor not in visited:
				queue.append(neighbor)
				visited[neighbor] = true # Essentially this just adds to dictionary; don't care about the value

	print("Couldn't find a valid point")
	return grid_point

## Takes grid point and returns AStar point ID. Requires grid point, not world point.
func get_grid_point_id(grid_point: Vector2) -> int:
	return a_star.get_closest_point(ow.gridToWorld(grid_point))

func get_world_point_id(world_point: Vector2) -> int:
	return a_star.get_closest_point(world_point)

func get_id_world_position(_id: int) -> Vector2:
	return a_star.get_point_position(_id)

func get_id_grid_position(_id: int) -> Vector2:
	var worldPos = get_id_world_position(_id)
	return ow.worldToGrid(worldPos)
