class_name CellArea
extends Area2D

var collison: CollisionShape2D
var collision_size: float = 40.0

var cell_data: CellData = null
var cell_select_box: CellSelectBox = null
var is_selected: bool = false
	
func _ready():
	collison = get_node("CollisionShape2D") # Move to on ready? 
	collison.shape.size = Vector2(collision_size, collision_size)
	monitoring = false
