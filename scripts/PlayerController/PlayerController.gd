class_name PlayerController
extends Node2D

@onready var main = get_tree().root.get_node("Main")
@onready var ow = main.get_node("Overworld")

@onready var ui = main.get_node("CanvasLayer").get_node("UI")
@onready var hud: HUD = ui.get_node("HUD")

# TESTING 
@onready var select_panel: Panel = $SelectPanel
@onready var select_panel_area: Area2D = $Area2D
@onready var select_panel_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var select_panel_collision_shape: Shape2D = select_panel_collision.shape

@onready var cell_select_box: PackedScene = preload("res://scenes/PlayerController/cell_select_box.tscn")

var areas_entered: int = 0

var cell_select_box_array: Array[CellSelectBox] = []
var selected_cell_array: Array[CellData] = []
var cell_index_to_remove_array: Array[int]

var selection_start
var selection_rect
var is_selecting: bool

var is_selecting_occupiers: bool = false
var is_selecting_floors: bool = false
var selection_mismatch: bool = false
var on_select_panel_area_entered_count = 0

func _ready():
	pass
	select_panel_area.area_entered.connect(on_select_panel_area_entered)
	select_panel_area.area_exited.connect(on_select_panel_area_exited)

func _process(_delta):

	# pass
	if is_selecting:
		if Input.is_action_just_released("left_click"):
			reset_select_panel()
			return

		# Continuously update the selection rectangle to match the mouse position
		var current_mouse_position = get_global_mouse_position()

		selection_rect = Rect2(selection_start, current_mouse_position - selection_start).abs()

		select_panel.position = selection_rect.position
		select_panel.size = selection_rect.size

		select_panel_collision.position = selection_rect.position + (selection_rect.size / 2)
		select_panel_collision.shape.size = selection_rect.size
				
		# End position is wrong and needs to be set diff.
		# Probably needs to be the current mouse position ? 
		# Also don't trust console outputs when outputting this much data

		# Find the area of the rectangle
		# Find the starting position and end position of the rectangle
		# Calculate all the points in between those points

		# print("Start vector: ", selection_start)
		# print("End vector: ", current_mouse_position - selection_start)
		# print("Start vector[grid]: ", ow.worldToGrid(selection_start))
		# print("End vector[grid]: ", ow.worldToGrid(current_mouse_position - selection_start))
		# print("SelectionRect size ", selection_rect.size)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start Selection
			is_selecting = true
			select_panel_collision.disabled = false
			selection_start = get_global_mouse_position()
			select_panel.position = selection_start
			select_panel.size = Vector2()

			select_panel_collision.position = selection_start
			select_panel_collision.shape.size = Vector2()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			reset_select_panel()

func on_select_panel_area_entered(entering_cell_area):
	# Only process if intruder is CellArea type
	if entering_cell_area is CellArea:
		entering_cell_area.is_selected = true
		entering_cell_area.cell_select_box.sprite.visible = true

# func on_select_panel_area_entered(entering_cell_area):
# 	# Only process if intruder is CellArea type
# 	if entering_cell_area is CellArea:
# 		if entering_cell_area.cell_data:
# 			if entering_cell_area.cell_data.occupier: 
# 				if entering_cell_area.cell_data.occupier is Plant:
# 				# print("Entering area: ", entering_cell_area)
# 				# Ensure that cell area has not already been selected and if not, mark as selected
# 					if not (entering_cell_area.is_selected):
# 						on_select_panel_area_entered_count += 1
# 						# print("on_select_panel_area_entered_count: ", on_select_panel_area_entered_count)
# 						entering_cell_area.is_selected = true
# 						entering_cell_area.cell_select_box.sprite.visible = true
# 						# # #Create a new_cell_select_box and link it to the detected cell area
# 						# var new_cell_select_box: CellSelectBox = cell_select_box.instantiate()
# 						# entering_cell_area.cell_select_box = new_cell_select_box
# 						# # #Set the position of new_cell_select_box and spawn it in the world
# 						# new_cell_select_box.position = entering_cell_area.cell_data.world_pos
# 						# add_child(new_cell_select_box)

func on_select_panel_area_exited(exiting_cell_area):
	# print("on_select_panel_area_exited called")
	if exiting_cell_area is CellArea:
		if exiting_cell_area.is_selected == true:
			exiting_cell_area.is_selected = false
			exiting_cell_area.cell_select_box.sprite.visible = false
			# exiting_cell_area.cell_select_box.queue_free()

## Reset select_panel, clear `selected_cells_array`
func reset_select_panel():
	is_selecting = false
	select_panel_collision.disabled = true
	select_panel_collision.shape.size = Vector2()
	select_panel.size = Vector2()
	clear_selected_cells_array()

func clear_selected_cells_array() -> void:
	selected_cell_array.clear()

## Check that the occupier objects of all CellData objects in the array have the same 'cname' value
func is_array_one_occupier_name(array) -> bool:
	var match_cname = array[0].occupier.cname
	for i in array.slice(1,array.size()):
		var curr_cname = i.occupier.cname
		if not (curr_cname == match_cname):
			return false
	return true

## Check that the floor_data objects of all CellData objects in the array have the same 'cname' value
func is_array_one_floor_name(array) -> bool:
	var match_cname = array[0].floor_data.cname
	for i in array.slice(1,array.size()):
		var curr_cname = i.floor_data.cname
		if not (curr_cname == match_cname):
			return false
	return true

	# if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	# 	if event.pressed:
	# 		var clicked_world_pos: Vector2 = get_global_mouse_position()
	# 		var clicked_grid_pos: Vector2 = ow.worldToGrid(clicked_world_pos)

	# 		if ow.grid.has(clicked_grid_pos):
	# 			var selected_cell = ow.grid[clicked_grid_pos]
	# 			var new_cell_select_box: CellSelectBox = cell_select_box.instantiate()
	# 			new_cell_select_box.position = selected_cell.world_pos

	# 			# If shift clicking, add cell to already selected
	# 			if Input.is_action_pressed("shift"):
	# 				if selected_cell not in selected_cell_array: 
	# 					cell_select_box_array.append(new_cell_select_box)
	# 					selected_cell_array.append(selected_cell)
	# 					add_child(new_cell_select_box)

	# 			# Else, Clear all previously selected cells and add newly selected cell
	# 			else:
	# 				clear_cell_select_box_array()
	# 				clear_selected_cells_array()
	# 				cell_select_box_array.append(new_cell_select_box)
	# 				selected_cell_array.append(selected_cell)
	# 				add_child(new_cell_select_box)

	# 			if selected_cell_array.size() == 1:
	# 				selection_mismatch = false
	# 				if selected_cell.occupier:
	# 					is_selecting_occupiers = true
	# 					is_selecting_floors = false
	# 				elif selected_cell.floor_data:
	# 					is_selecting_floors = true
	# 					is_selecting_occupiers = false

	# 			if selection_mismatch:
	# 				return

	# 			else:
	# 				if is_selecting_occupiers and selected_cell.occupier == null:
	# 					hud.set_inspector_name_label_text("Multiple objects selected")
	# 					selection_mismatch = true
	# 					return
	# 				elif is_selecting_floors and selected_cell.occupier:
	# 					hud.set_inspector_name_label_text("Multiple tiles selected")
	# 					selection_mismatch = true
	# 					return

	# 			if selected_cell.occupier:
	# 				if selected_cell_array.size() == 1:
	# 					hud.set_inspector_name_label_text(selected_cell.occupier.inspector_name)
	# 				else:
	# 					if is_array_one_occupier_name(selected_cell_array):
	# 						var text = selected_cell.occupier.inspector_name + " x" + str(cell_select_box_array.size())
	# 						hud.set_inspector_name_label_text(text)
	# 					else:
	# 						hud.set_inspector_name_label_text("Multiple objects selected")
	# 			elif selected_cell.floor_data:
	# 				if selected_cell_array.size() == 1:
	# 					hud.set_inspector_name_label_text(selected_cell.floor_data.inspector_name)
	# 				else:
	# 					if is_array_one_floor_name(selected_cell_array):
	# 						var text = selected_cell.floor_data.inspector_name + " x" + str(cell_select_box_array.size())
	# 						hud.set_inspector_name_label_text(text)
	# 					else:
	# 						hud.set_inspector_name_label_text("Multiple tiles selected")
