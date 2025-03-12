class_name CellData
extends Object

signal cellChanged(_pos: Vector2)
signal navChanged(_pos: Vector2)

## Grid point
var pos: Vector2 

func _init(_pos: Vector2):
	pos = _pos

var floor_data: FloorData = null:
	set(value):
		floor_data = value
		emit_signal("cellChanged", pos)
	get:
		return floor_data
	
var occupier = null:
	set(value):
		occupier = value
		emit_signal("cellChanged", pos)
	get:
		return occupier
	
var navigable: bool = true :
	set(value):
		navigable = value
		emit_signal("navChanged", pos)
	get:
		return navigable