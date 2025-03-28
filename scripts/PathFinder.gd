class_name PathFinder
extends Node

# Make untis move through the center of the point not top right ? 

var a_star = AStar2D.new()
@onready var main = get_tree().root.get_node("Main")
@onready var ow = main.get_node("Overworld")

const DIRECTIONS: Array[Vector2] = [(Vector2.UP + Vector2.LEFT), Vector2.UP, (Vector2.UP + Vector2.RIGHT), 
Vector2.LEFT, Vector2.RIGHT, (Vector2.DOWN + Vector2.LEFT), Vector2.DOWN, (Vector2.DOWN + Vector2.RIGHT)]

func initialize():
	add_all_points()
	connect_all_points()

func get_astar_path(point_a: Vector2, point_b: Vector2) -> PackedVector2Array:
	# Both param points are grid points
	# TODO: Need to unreserve points!
	if ow.grid.has(point_b):
		# print("my DESTINATION point is", Constants.grid_to_world(point_b))
		# Find a new nearby and unreserved destination grid point if point_b is reserved
		if ow.grid[point_b].is_reserved or (not ow.grid[point_b].is_navigable):
			# print("my ORIGINAL point of ", Constants.grid_to_world(point_b), " was reserved!")
			point_b = find_valid_point(point_b)
			# print("my NEW point of ", Constants.grid_to_world(point_b), " is NOT reserved!")

		# ow.grid[point_b].is_reserved = true
		# print("ow.grid[", point_b, "].is_reserved = ", ow.grid[point_b].is_reserved)

		if not ow.grid[point_a].is_navigable:
			point_a = find_valid_point(point_a)

		# ID's are Astar node internal id's
		var a_id: int = get_grid_point_id(point_a)
		var b_id: int = get_grid_point_id(point_b)
		var a_star_path: PackedVector2Array = a_star.get_point_path(a_id, b_id, false)
		
		# # Not working
		# if not ow.grid[Constants.world_to_grid(a_star_path[0])].is_navigable:
		# 	a_star_path.remove_at(0)

		return a_star_path

	# If the target point doesn't exist, return an empty path
	return PackedVector2Array()

## Configure AStar node with all overworld grid points. AStar stores this as id + Vector2 position and uses points to determine
## pathing
func add_all_points():
	var cur_id = 0
	for point in ow.grid:
		a_star.add_point(cur_id, ow.gridToWorld(point))
		cur_id += 1

## Iterate over all overworld grid points and run connect_point on them. Used to connect all points to eachother in overworld.
func connect_all_points():
	for point in ow.grid:
		connect_point(point)
		ow.grid[point].nav_changed.connect(on_nav_changed) 

func connect_point(grid_point: Vector2) -> void:
	var grid_point_id = get_grid_point_id(grid_point)
	# Don't connect a point to its neighbors if it isn't navigable itself
	# This will save time by not processing mountain tiles
	if not(ow.grid[grid_point].is_navigable):
		return 
		
	for direction in DIRECTIONS:
		var neighbor = grid_point + direction
		var neighbor_id = get_grid_point_id(neighbor)

		if ow.grid.has(neighbor) and ow.grid[neighbor].is_navigable:
			a_star.connect_points(grid_point_id, neighbor_id)

## Disconnect point from all of its neighbors. Requires grid_point
func disconnect_point(grid_point: Vector2) -> void:
	var _point_id = get_grid_point_id(grid_point)
	for direction in DIRECTIONS:
		var neighbor = grid_point + direction
		var neighbor_id = get_grid_point_id(neighbor)
		a_star.disconnect_points(_point_id, neighbor_id)

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
			
# func find_valid_point(grid_point: Vector2) -> Vector2:
# 	# Check all the direction around the starting one
# 	# If any of them are unreserved, set that as the new target!
# 	# If none of them are, perform the same operation with the nodes surrounding the start point as the new start points
# 	var x = find_valid_point_helper(grid_point)
# 	# print("New valid point: ", x)
# 	return x

# func find_valid_point_helper(grid_point: Vector2):
# 	# Check to see if this is the unreserved point we're looking for 
# 	if not ow.grid[grid_point].is_reserved:
# 		return grid_point

# 	for direction in Constants.ORTHOGONAL_DIRECTIONS:
# 		var neighbor_point: Vector2 = grid_point + direction
# 		if ow.grid.has(neighbor_point): # Only recurse on point that is a valid grid point
# 			if not ow.grid[neighbor_point].is_reserved:
# 				return neighbor_point
# 			else:
# 				return find_valid_point_helper(neighbor_point)

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
