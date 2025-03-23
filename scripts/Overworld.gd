class_name Overworld
extends Node2D

@onready var main = get_tree().root.get_node("Main")
# @onready var ui = main.get_node("UI")
@onready var terrain_layer: TileMapLayer = get_node("TerrainLayer")
@onready var structure_layer: TileMapLayer = get_node("StructureLayer")

@export var noise_texture: NoiseTexture2D
@export var grid_width: int = 100
@export var grid_height: int = 100
@export var cell_size: int = 64
@export var show_debug: bool = true

var grid: Dictionary[Vector2, CellData] = {}
var grid_area: float = grid_width * grid_height
var noise: Noise
var rng = RandomNumberGenerator.new()

@onready var cell_area:PackedScene = preload("res://scenes/PlayerController/cell_area.tscn")
@onready var cell_select_box: PackedScene = preload("res://scenes/PlayerController/cell_select_box.tscn")

var floor_resources: Dictionary[String, Resource] = {
	"mountain": preload("res://data/floor/mountain.tres"),
	"grass": preload("res://data/floor/grass.tres"),
	"water": preload("res://data/floor/water.tres")}

var mineral_resources: Dictionary[String, Resource] = {
	"stone": preload("res://data/mineral/stone.tres"),
	"iron": preload("res://data/mineral/iron.tres"),
	"copper": preload("res://data/mineral/copper.tres"),
	"titanium": preload("res://data/mineral/titanium.tres"),
	"gold": preload("res://data/mineral/gold.tres")}

var mineral_spawn_chances: Array = [
[mineral_resources["stone"], 98.5],
[mineral_resources["iron"],1.125], 
[mineral_resources["copper"], 0.125],
[mineral_resources["titanium"], 0.125], 
[mineral_resources["gold"], 0.125]]

var plant_threshold: float = .10 # Chance that any type of plant will spawn on a grass tile. Higher value, more plants overall
var plant_resources: Dictionary[String, Resource] = {
	"oak_tree": preload("res://scenes/plants/oak_tree.tscn"),
	"wheat": preload("res://scenes/plants/wheat.tscn"),
	"yellow_bush": preload("res://scenes/plants/yellow_bush.tscn"),
	"blue_bush": preload("res://scenes/plants/blue_bush.tscn"),
	"red_bush": preload("res://scenes/plants/red_bush.tscn")
}
var plant_spawn_chances: Array = [
	[plant_resources["oak_tree"], 85.0],
	[plant_resources["wheat"], 8.0],
	[plant_resources["yellow_bush"], 4.0],
	[plant_resources["blue_bush"], 2.0],
	[plant_resources["red_bush"], 1.0]
]

# Thresholds are set relative to the calculated min and max of a noise map
var mountain_threshold: float 
var water_threshold: float

# Distance from min and max of noise map to spawn floor type. 
# Higher values; more of that floor type
var mountain_offset: float = .1
var water_offset: float = .025

# Used for specific reiteration after initial grid generation on certain tile types
var grass_cells: Array[Vector2] = []
var mountain_cells: Array[CellData] = []
var water_cells: Array[Vector2] = []

var jitter_padding: float = .55
var jitter_min: float = -1 * ((cell_size / 2) - ((cell_size / 2) * jitter_padding))
var jitter_max: float = ((cell_size / 2) - ((cell_size / 2) * jitter_padding))

func _ready():
	var r = rng.randi_range(-10000, 10000)
	noise_texture.noise.seed = r
	noise = noise_texture.noise

## Run all functions to initialize and cofigure overworld data. 
func initialize_overworld():
	generateGrid()
	process_mountain_cells()

## Create and populate `grid` dictionary with Vector2 positions and corresponding `CellData`, `CellArea`, and 
## `CellSelectBox` objects. Calculate the floor type and instantiate relevant occupiers
func generateGrid():
	var noise_range = calc_noise_range(noise)
	var sample_noise_min = noise_range[0]
	var sample_noise_max = noise_range[1]

	mountain_threshold = sample_noise_max - mountain_offset
	water_threshold = sample_noise_min + water_offset

	for x in grid_width:
		for y in grid_height:
			# Access current positions noise value
			var noise_point_value = noise.get_noise_2d(x,y)

			# Create a new CellData object; this is not a node and is only an object stored in 'grid'
			var new_cell:CellData = CellData.new(Vector2(x,y), gridToWorld(Vector2(x,y)), cell_size)
			grid[new_cell.pos] = new_cell

			# Create a new CellArea to detect collisons for new cell. This is an Area2D node and is added to tree
			var new_cell_area: CellArea = cell_area.instantiate()
			new_cell_area.position = new_cell.center
			new_cell_area.cell_data = new_cell # Link references in cell and cell area
			new_cell.cell_area = new_cell_area # ^
			new_cell_area.collision_layer = Constants.layer_mapping["no_occupier"] # Default, updated later if required
			self.add_child(new_cell_area)

			# Create a new CellSelectBox to display a selected CellArea
			var new_cell_select_box: CellSelectBox = cell_select_box.instantiate()
			new_cell_area.cell_select_box = new_cell_select_box
			self.add_child(new_cell_select_box)
			new_cell_select_box.position = new_cell.world_pos

			# Set floor tile for this new cell
			calc_cell_floor_type(noise_point_value, new_cell)

			debug(x,y)

## Calculate what type of floor resource should be assigned to cell, based on grid_height values from NoiseTexture2D noise.
## Set layer value for CellArea
func calc_cell_floor_type(noise_point_value: float, new_cell: CellData) -> void:
	var r_plant = rng.randf_range(0, 1)

	# Cell is a mountain
	if noise_point_value >= mountain_threshold:
		new_cell.floor_data = floor_resources["mountain"] 
		refreshCellFloor(terrain_layer, new_cell.pos)

		var mineral_resource: MineralData = get_weighted_random(mineral_spawn_chances)
		new_cell.mineral_data = mineral_resource # CellData occupier and navigable are set when mineral_data is set
		mountain_cells.append(new_cell)
		refreshCellMineral(structure_layer, new_cell.pos)
		new_cell.cell_area.collision_layer = Constants.layer_mapping["mineral"]

	# Cell is grass
	elif noise_point_value < mountain_threshold and noise_point_value >  water_threshold:
		new_cell.floor_data = floor_resources["grass"]
		refreshCellFloor(terrain_layer, new_cell.pos)

		# Check if a plant should be placed on new grass cell
		if r_plant < plant_threshold:
			var plant: PackedScene = get_weighted_random(plant_spawn_chances)
			var new_plant: Plant = plant.instantiate()
			new_cell.plant_data = new_plant

			if new_plant.is_tree:
				#trees are fucking annoying cause they take up more than 1 tile, so manually place the root 1 cell up
				new_plant.position = get_pos_with_jitter(new_cell.world_pos + Vector2(0, (-1 * cell_size)))
				self.add_child(new_plant)
				new_plant.z_index = 2 # Move tree infront of other objects 
				new_cell.cell_area.collision_layer = Constants.layer_mapping["tree"]
			else:
				new_plant.position = get_pos_with_jitter(new_cell.world_pos)
				self.add_child(new_plant)
				new_cell.cell_area.collision_layer = Constants.layer_mapping["plant"]

	# Cell is water
	elif noise_point_value <= water_threshold:
		new_cell.floor_data = floor_resources["water"]
		refreshCellFloor(terrain_layer, new_cell.pos)

		# Since this cell currently cannot have objects don't set a layer. May need to be added in the future, like 
		# when you can build water structures

## Set terrain tile layer floor data. Uses godot built-in tile layer feature 'set_cell'
func refreshCellFloor(layer: TerrainLayer, _pos: Vector2) -> void: 
	var data = grid[_pos] # Reference to a CellData object
	layer.set_cell(_pos, data.floor_data.id, data.floor_data.coords)

## Set structure layer mineral data. DOES NOT USE GODOT BUILT-IN TILE LAYER FEATURE. Uses 'BetterTerrain' to help with autotiles
## The cell that is being refreshed must already have its mineral_data field updated with the mineral to refresh to.
func refreshCellMineral(layer: StructureLayer, _pos: Vector2) -> void: 
	var data = grid[_pos] # Reference to a CellData object
	BetterTerrain.set_cell(layer, _pos, data.mineral_data.terrain_id)

func process_mountain_cells() -> void:
	for cell in mountain_cells:
		# Generate veins on non-stone minerals
		if not (cell.occupier is MineralData and cell.occupier.cname == "stone"):
			gen_mineral_vein(cell.mineral_data, cell.pos)

	# Once mineral veins are created, update all mountain cells to trigger autotiling
	for cell in mountain_cells: 
		BetterTerrain.update_terrain_cell(structure_layer, cell.pos, false)

## Set up base values for vein creation. Call gen_mineral_vein_helper() to handle recursively creating minerals
func gen_mineral_vein(initial_mineral: MineralData, mineral_pos: Vector2) -> void:
	var i: int = 0
	var computed_growth = initial_mineral.vein_growth - (initial_mineral.vein_growth_reduction * i)
	gen_mineral_vein_helper(initial_mineral, mineral_pos, computed_growth, i)

## Recursively create mineral nodes around current mineral position
## Each stone mineral in 4 orthagonal directions around current mineral have a chance to become the mineral. 
## The chance of transforming into this new mineral becomes smaller the further from original mineral node
func gen_mineral_vein_helper(mineral: MineralData, mineral_pos: Vector2, computed_growth: float, i: int):
	var directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
	i += 1
	if computed_growth > 0:
		for d in directions:
			var r = rng.randi_range(0,100)
			if r < computed_growth:
				if grid.has(mineral_pos + d):
					# Get reference to the cell in the current direction
					var neighbor_mineral_cell = grid[mineral_pos + d]

					# Only spawn if neighbor cell occupier is stone
					if neighbor_mineral_cell.occupier is MineralData and neighbor_mineral_cell.occupier.cname == "stone":
						neighbor_mineral_cell.mineral_data = mineral
						refreshCellMineral(structure_layer, neighbor_mineral_cell.pos)
						gen_mineral_vein_helper(neighbor_mineral_cell.mineral_data, neighbor_mineral_cell.pos, 
						(mineral.vein_growth - (mineral.vein_growth_reduction * i)), i)
	else: 
		return

## Select a scene resource using weighted random chance. Return Resource (based on the Resource type supplied by `spawn_chance_array`).
## `spawn_chance_array` must be an array with structure Array = ( (Resource, spawn_chance: float), (Resource, spawn_chance: float), etc...)
## https://www.youtube.com/watch?v=MGTQWV1VfWk
func get_weighted_random(spawn_chance_array) -> Resource:
	var total = 0
	for i in range(len(spawn_chance_array)):
		total += spawn_chance_array[i][1]

	var r = rng.randf() * total

	for i in range(0, len(spawn_chance_array)):
		var selection = spawn_chance_array[i]
		if r < selection[1]:
			return selection[0]
		r -= selection[1]
	return # Only here to allow for typed return signature. Should never return here

## Takes in world point and returns world point with random position jitter applied to x axis
## Used for tree position randomization. Starting point is the bottom center of a cell
func get_pos_with_jitter(world_pos: Vector2) -> Vector2:
	var x_jitter = rng.randf_range(jitter_min, jitter_max)

	var new_world_pos = world_pos - Vector2(x_jitter, 0)
	return new_world_pos
	
## Sample random nodes from the noise texture. Use these to approximate max and min grid_height values.
## Amount of random nodes sampled can vary based on `sample_percent` (defined inside the function).
func calc_noise_range(n: Noise) -> Array:
	var sample_noise_min = 0
	var sample_noise_max = 0
	var sample_percent = .25
	for i in range(grid_area * sample_percent):
		var sample_x = rng.randi_range(0, grid_width)
		var sample_y = rng.randi_range(0, grid_height)
		var sample_noise_point_value = n.get_noise_2d(sample_x, sample_y)

		if sample_noise_point_value > sample_noise_max:
			sample_noise_max = sample_noise_point_value
		elif sample_noise_point_value < sample_noise_min:
			sample_noise_min = sample_noise_point_value

	return [sample_noise_min, sample_noise_max]

## Show grid lines and label grid position for specific point in `grid`. 
func debug(x:int, y:int):
	if show_debug:
		var label = Label.new()
		label.position = gridToWorld(Vector2(x,y))
		label.text = str(Vector2i(x,y))
		add_child(label)

		var rect = ReferenceRect.new()
		rect.position = gridToWorld(Vector2(x,y))
		rect.size = Vector2(cell_size, cell_size)
		rect.editor_only = false
		add_child(rect)

## Return world position of grid coordinate.
func gridToWorld(_pos: Vector2) -> Vector2:
	return _pos * cell_size

## Return grid position of world coordinate.
func worldToGrid(_pos: Vector2) -> Vector2:
	return floor(_pos / cell_size)
