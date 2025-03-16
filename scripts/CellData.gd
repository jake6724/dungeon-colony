class_name CellData
extends Object

signal cellChanged(_pos: Vector2)
signal navChanged(_pos: Vector2)

## Grid point
var pos: Vector2
## World point
var world_pos: Vector2
## World point 
var center: Vector2
## World point
var center_bottom
var size: int

func _init(_pos: Vector2, _world_pos: Vector2, _size: int):
	pos = _pos
	size = _size
	world_pos = _world_pos
	center = Vector2(world_pos[0] + (size / 2), world_pos[1] + (size / 2))
	center_bottom = Vector2(world_pos[0] + (size / 2), world_pos[1] + size)

var floor_data: FloorData = null:
	set(value):
		floor_data = value
		emit_signal("cellChanged", pos)
	get:
		return floor_data

var structure_data: StructureData = null: 
	set(value):
		structure_data = value
		occupier = value
		emit_signal("cellChanged", pos)
	get:
		return structure_data

var mineral_data: Resource = null:
	set(value):
		mineral_data = value
		occupier = value
		is_navigable = false
		emit_signal("cellChanged", pos)
	get:
		return mineral_data

# Convert this to store the object on it  ?????
var occupier = null:
	set(value):
		occupier = value
		# emit_signal("cellChanged", pos)
	get:
		return occupier

var is_navigable: bool = true :
	set(value):
		is_navigable = value
		emit_signal("navChanged", pos)
	get:
		return is_navigable