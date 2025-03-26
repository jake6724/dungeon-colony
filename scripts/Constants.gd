extends Node
# This is autoloaded into the scene
# Project settings > Globals tab > Autoload

const cell_size = 64

const DIRECTIONS: Array[Vector2] = [(Vector2.UP + Vector2.LEFT), Vector2.UP, (Vector2.UP + Vector2.RIGHT), 
Vector2.LEFT, Vector2.RIGHT, (Vector2.DOWN + Vector2.LEFT), Vector2.DOWN, (Vector2.DOWN + Vector2.RIGHT)]

const ORTHOGONAL_DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN]

# Layers are represented by Binary numbers. Layer 1 = 1, layer 2 = 2, layer 3 = 4, layer 4 = 8.
# To find a layer number, you will do: layer_number = 2 ^ (n - 1)
# So layer 13 would be set as 2 ^ (13 - 1) = 4096
# To set multiple layers, add their bitmask (the binary number) representation together
# To set layer 4 and 13 = 8 + 4096 = 5004 
# This library provides an easier method to map and track layers. Maybe move out to a constants file
## All keys are singular, e.i. no_collision, plant, etc.
const layer_mapping: Dictionary[String, int] = {
	"no_collision": 1,
	"no_occupier": 2,
	"plant": 4,
	"mineral": 8,
	"tree": 16,
	"harvest": 32,
	"structure": 64,
	"item": 128,
	"unit": 256,
	"unit_item": 512,
	"all_layer": 4294967295
}

const z_index_mapping: Dictionary[String, int] = {
	"floor": 1,
	"structure": 2,
	"player_unit_select_sprite": 30,
	"player_unit_sprite": 31,
	"tree_top": 41,
	"tree_bottom": 29,
	"GUI": 999,
	"debug": 1001
}

func get_weighted_random(spawn_chance_array) -> Variant:
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

var rng = RandomNumberGenerator.new() # Maybe set a seed somewhere ? 

## Return world position of grid coordinate.
func grid_to_world(pos: Vector2) -> Vector2:
	return pos * cell_size

## Return grid position of world coordinate.
func world_to_grid(pos: Vector2) -> Vector2:
	return floor(pos / cell_size)

# func get_center_point(world_position):
	
enum weapon_damage_types {SLASH, PIERCE, BLUNT}
enum magic_damage_types {FIRE, ICE, STORM}
