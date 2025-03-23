extends Node
# This is autoloaded into the scene
# Project settings > Globals tab > Autoload

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