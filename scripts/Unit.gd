class_name Unit
extends Area2D

@onready var main = get_tree().root.get_node("Main")
@onready var ow = main.get_node("Overworld")
# @onready var terrain_layer: TerrainLayer = ow.get_node("TerrainLayer")
@onready var pf: PathFinder = ow.get_node("PathFinding")

var data: UnitData = UnitData.new()

var path: PackedVector2Array = []
var pos: Vector2 :
	get:
		return pos
	set(value):
		pos = value

func _ready():
	pos = ow.worldToGrid(position)

func _process(delta):
	move(delta)
	queue_redraw()

func move(delta):
	# Check if there are more points in the path to traverse
	if path.size() > 0:
		if position.distance_to(path[0]) < 5:
			pos = ow.worldToGrid(path[0])
			position = path[0]
			path.remove_at(0)
		else:
			pos = ow.worldToGrid(position)
			position += (path[0] - position).normalized() * data.speed * delta  

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var clicked = ow.worldToGrid(get_global_mouse_position())

			if ow.grid.has(ow.worldToGrid(clicked)):
				path = pf.getPath(pos, clicked)
			
			else: 
				print("Invalid target cell")
