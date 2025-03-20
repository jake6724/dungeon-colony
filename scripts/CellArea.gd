class_name CellArea
extends Area2D

var collison: CollisionShape2D
var collision_size: float = 40.0

var cell_data: CellData = null
var cell_select_box: CellSelectBox = null
var is_selected: bool = false
var preserve: bool = false
	
func _ready():
	collison = get_node("CollisionShape2D") # Move to on ready? 
	collison.shape.size = Vector2(collision_size, collision_size)
	monitoring = false
	collision_mask = 0 # Might be redundant since monitoring is false
	z_index = 99 # Make a constants file and dictionary with values for all these
