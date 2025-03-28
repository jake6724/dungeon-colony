class_name Unit
extends Node2D

# @onready var main = get_tree().root.get_node("Main")
# @onready var ow: Overworld = main.get_node("Overworld")
# @onready var pf: PathFinder = ow.get_node("PathFinding")


# var data: UnitData = UnitData.new()
# var is_selected: bool = false
# var preserve: bool = false
# var target_line: Line2D
# var max_range: Vector2 = Vector2(100, 100)

# var path: PackedVector2Array = []
# var pos: Vector2
# var center: Vector2

# func _ready():
# 	pos = ow.worldToGrid(position)
# 	collision_layer = Constants.layer_mapping["unit"]

# func _process(delta):
# 	move(delta)
# 	queue_redraw()

# func move(delta):
# 	# Check if there are more points in the path to traverse
# 	if path.size() > 0:
# 		if position.distance_to(path[0]) < 5:
# 			pos = ow.worldToGrid(path[0])
# 			position = path[0]
# 			path.remove_at(0)
# 		else:
# 			pos = ow.worldToGrid(position)
# 			position += (path[0] - position).normalized() * data.speed * delta
