class_name Grid
extends TileMap

@export var width: int = 100
@export var height: int = 100
@export var cell_size: int = 64
@export var show_debug: bool = true
@export var noise_texture: NoiseTexture2D
var noise: Noise
var grid: Dictionary = {}

var mountain_offset: float = .4
var water_offset: float = .0

var grass_cells: Array[Vector2] = []
var mountain_cells: Array[Vector2] = []
var water_cells: Array[Vector2] = []

func _ready():
	var rng = RandomNumberGenerator.new()
	var r = rng.randi_range(-10000, 10000)
	noise_texture.noise.seed = r

	print("Norm:", noise_texture.normalize)

	noise = noise_texture.noise
	generateGrid()

func generateGrid():
	# Find noise range
	# This really slows down the code
	var noise_max = 0
	var noise_min = 0
	for x in width:
		for y in height:
			var point_noise_val = noise.get_noise_2d(x,y)
			if point_noise_val > noise_max:
				noise_max = point_noise_val
			elif point_noise_val < noise_min:
				noise_min = point_noise_val
	print("Noise max:", noise_max)
	print("Noise min:", noise_min)
	

	# Calc terrain thresholds
	var mountain_threshold = noise_max - mountain_offset
	var water_threshold = noise_min + water_offset

	for x in width:
		for y in height:
			var point_noise_val = noise.get_noise_2d(x,y)

			# Cell is a mountain
			if point_noise_val >= mountain_threshold:
				var new_cell:CellData = CellData.new(Vector2(x,y))
				grid[new_cell.pos] = new_cell
				new_cell.floor_data = preload("res://data/floor/mountain.tres")
				new_cell.navigable = false
				refreshTile(Vector2(x,y))
			
			# Cell is grass
			elif point_noise_val < mountain_threshold and point_noise_val >  water_threshold:
				grid[Vector2(x,y)] = CellData.new(Vector2(x,y))
				grid[Vector2(x,y)].floor_data = preload("res://data/floor/grass.tres")
				refreshTile(Vector2(x,y))

			# Cell is water
			elif point_noise_val <= water_threshold:
				grid[Vector2(x,y)] = CellData.new(Vector2(x,y))
				grid[Vector2(x,y)].floor_data = preload("res://data/floor/water.tres")
				refreshTile(Vector2(x,y))
			
			# Debug
			if show_debug:
				var label = Label.new()
				label.position = gridToWorld(Vector2(x,y))
				label.text = str(Vector2(x,y))
				add_child(label)

func gridToWorld(_pos: Vector2) -> Vector2:
	return _pos * cell_size

func worldToGrid(_pos: Vector2) -> Vector2:
	return floor(_pos / cell_size)

## Get a reference to the CellData at pos, by accessing grid dictionary.
## Set the Tileset tile data based on the CellData object's floor_data object.
## This function is what sets the PNG for the tile in the tilemap using 'set_cell'
func refreshTile(_pos: Vector2) -> void: 
	var data = grid[_pos] # Reference to a CellData object
	set_cell(data.floor_data.layer, _pos, data.floor_data.id, data.floor_data.coords)
