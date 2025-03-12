extends Node2D

@export var noise_height_texture: NoiseTexture2D
var noise: Noise
var width: int = 100
var height: int = 100

@onready var tile_map = $TileMap

var grass_atlas = Vector2i(0,0)
var mountain_atlas = Vector2i()

var noise_val_arr = []

func _ready():
	noise = noise_height_texture.noise
	generate_world()

func generate_world():
	for x in range(width):
		for y in range(height):
			var noise_val = noise.get_noise_2d(x,y)
			if noise_val >= 0.0: 
				tile_map.set_cell(0, Vector2(x,y), 1, grass_atlas)
			elif noise_val < -0.4:
				tile_map.set_cell(0, Vector2(x,y), 2, mountain_atlas)
			
			noise_val_arr.append(noise_val)

	print("H: ", noise_val_arr.max())
	print("L:", noise_val_arr.min())