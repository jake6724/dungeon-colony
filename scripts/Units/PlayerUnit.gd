class_name PlayerUnit
extends Node2D

# Node References
@onready var main = get_tree().root.get_node("Main")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var pf: PathFinder = ow.get_node("PathFinding")

# Child Node References
@onready var sprite = get_node("UnitSprite")
@onready var selected_sprite = $SelectedSprite
@onready var area = get_node("UnitArea")
@onready var collision = area.get_node("UnitCollision")

# TODO tidy up all these
var data: UnitData = UnitData.new()
var is_selected: bool = false
var preserve: bool = false
var target_line: Line2D
var max_range: Vector2 = Vector2(1000, 1000)

var path: PackedVector2Array = []
var path_line: Line2D # TODO Make this line a resource 
var path_target_panel: Panel
var is_moving: bool = false


var grid_position: Vector2 = Vector2()
var center: Vector2

# ABILITY TESTING - NOT PERMANENT SET UP
var abilities_array: Array[AbilityData] = []
@export var test_ability_1: AbilityData
@export var test_ability_2: AbilityData
@export var test_ability_3: AbilityData
@export var test_ability_4: AbilityData
var ability_fireball = load("res://data/ability/character/fireball.tres")
var ability_iceball = load("res://data/ability/character/ice_ball.tres") 
var ability_stormball = load("res://data/ability/character/storm_ball.tres")
var ability_heal = load("res://data/ability/character/heal.tres")

func _ready():
	grid_position = ow.worldToGrid(position)
	# center = grid_position + Vector2(32,32)
	area.collision_layer = Constants.layer_mapping["unit"]
	sprite.z_index = Constants.z_index_mapping["player_unit_sprite"]
	selected_sprite.z_index = Constants.z_index_mapping["player_unit_select_sprite"]
	data.generate_new_unit_data()
	# data.print_unit_data()

	# Path Visualization
	path_line = Line2D.new()
	path_line.default_color = (Color(1.0, 1.0, 1.0, 0.500))
	path_line.width = 10
	path_line.z_index = Constants.z_index_mapping["GUI"]
	main.call_deferred("add_child", path_line) # Main is too busy setting up its own children to add immediately

	# Create Path Target Panel, set theme
	path_target_panel = Panel.new()
	path_target_panel.size = Vector2(Constants.cell_size, Constants.cell_size)
	var style_box = load("res://scripts/Units/path_target_panel_style.tres")
	path_target_panel.add_theme_stylebox_override("panel", style_box)
	main.call_deferred("add_child", path_target_panel)

	# # ABILITY TESTING - NOT PERMANENT SET UP
	if test_ability_1:
		abilities_array.append(test_ability_1)
	if test_ability_2:
		abilities_array.append(test_ability_2)
	if test_ability_3:
		abilities_array.append(test_ability_3)
	if test_ability_4:
		abilities_array.append(test_ability_4)
	# abilities_array.append(ability_fireball)
	# abilities_array.append(ability_iceball)
	# abilities_array.append(ability_stormball)
	# abilities_array.append(ability_heal)

func _process(delta):
	move(delta) 

func move(delta):
	# Check if there are more points in the path to traverse
	if path.size() > 0:
		is_moving = true
		if position.distance_to(path[0]) < 10:
			grid_position = Constants.world_to_grid(path[0])
			position = path[0]
			path.remove_at(0)
			path_line.points = path

			if path.size() == 0:
				path_target_panel.visible = false

		else:
			grid_position = Constants.world_to_grid(position)
			position += (path[0] - position).normalized() * data.base_move_speed * delta  
	else:
		is_moving = false


func set_path_to(target_grid_point) -> void:
	if ow.grid.has(target_grid_point):
		# Unreserve current grid
		ow.grid[grid_position].is_reserved = false
		# Reset path
		path = []

		if not ow.grid[target_grid_point].is_reserved:
			ow.grid[target_grid_point].is_reserved = true
			path = pf.getPath(grid_position, target_grid_point)
		else:
			# while path.size() < 0:
				for direction in Constants.ORTHOGONAL_DIRECTIONS:
					if ow.grid.has(target_grid_point + direction):
						if not ow.grid[(target_grid_point + direction)].is_reserved and ow.grid[(target_grid_point + direction)].is_navigable:
							target_grid_point = target_grid_point + direction
							ow.grid[target_grid_point].is_reserved = true
							path = pf.getPath(grid_position, target_grid_point)

		if path:
			path_line.points = path
			path_target_panel.position = path[-1]
			path_target_panel.visible = true
	else:
		print("Invalid grid point")

func find_valid_target_point_helper():
	# var target_found = false

	for direction in Constants.ORTHOGONAL_DIRECTIONS:
		pass

	pass
