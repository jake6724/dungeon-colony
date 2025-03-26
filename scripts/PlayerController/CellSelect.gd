class_name CellSelect
extends Node2D

################################################################
# TODOs
# 1. Double clicking should only select everything if you clicked a valid object, and then reset what
#		that object was when you're done

@onready var main = get_tree().root.get_node("Main")
@onready var pc: PlayerController = main.get_node("PlayerController")
@onready var gui: Node = pc.get_node("GUI")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var cell_select_gui: CellSelectGUI = gui.get_node("CellSelectGUI") # TODO: Update to the new system under PC
 
# Signals 
signal cell_area_selection_changed
# signal select_mode_changed
# signal update_cell_area_gui

# Cell selection data
var selected_cell_area_array: Array[CellArea] = []
var current_cell_select_mode: String = "unit_item"
var is_selected_cell_area_array_homogenous: bool
var selected_cell_area_array_inspector_name: String

func cell_select_ready():
	pc.select_panel_area.area_entered.connect(pc.on_select_panel_area_entered)
	pc.select_panel_area.area_exited.connect(pc.on_select_panel_area_exited)
	pc.select_panel_collision.disabled = true
	pc.select_panel_area.collision_layer = Constants.layer_mapping["no_collision"]
	pc.select_panel_area.collision_mask = Constants.layer_mapping[current_cell_select_mode]

	# Connect to cell_select_gui select mode signals
	cell_select_gui.select_mode_changed.connect(on_cell_select_mode_changed)
	cell_select_gui.mouse_entered_cell_select_gui.connect(pc.on_mouse_entered_gui)
	cell_select_gui.mouse_exited_cell_select_gui.connect(pc.on_mouse_exited_gui)


func cell_select_process():
	if pc.is_selecting:
		# Continuously update the selection rectangle to match the mouse position
		# select_panel and select_panel_area are set to match this rectangle, it does not interact with cells
		pc.current_mouse_position = get_global_mouse_position()
		pc.select_rect = Rect2(pc.selection_start, pc.current_mouse_position - pc.selection_start).abs()

		if pc.select_rect.size > Vector2(1,1):
			# Select panel is a visual indicator for player. 
			# select_panel_area and collision actually detect cell area collisions
			pc.select_panel.position = pc.select_rect.position
			pc.select_panel.size = pc.select_rect.size

			pc.select_panel_collision.position = pc.select_rect.position + (pc.select_rect.size / 2) # scales out from center for some reason
			pc.select_panel_collision.shape.size = pc.select_rect.size

func cell_select_input(event):
	if pc.is_input_enabled:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_action_just_released("left_click"):
				reset_select_panel_preserve_selected_cell_areas()
				update_cell_select_gui_data()
				cell_area_selection_changed.emit()
				return

			# Handle double clicking
			# TODO: Double clicking shouldn't care about select mode; instead it should just select
			# every cell_area that has the same occupier cname(?) as the object that was just double clicked
			if event.double_click:
				pc.select_panel.visible = false
				pc.select_panel_collision.disabled = false

				var new_size = Vector2((get_viewport().size)) / pc.camera.zoom
				var new_position = pc.camera.position - (new_size / 2)

				pc.select_panel.size = new_size
				pc.select_panel.position = new_position

				pc.select_panel_collision.shape.size = new_size
				pc.select_panel_collision.position = new_position + (new_size / 2)
				return # Do not continue to process input
			
			if event.pressed:
				# Only reset previously selected data if shift is not held during current click
				if not(Input.is_action_pressed("shift")):
					release_selected_cell_areas()

				# Handle individual cell selection
				# TODO: This needs to take into account the select mode
				pc.selection_start = get_global_mouse_position()
				var selection_start_grid_pos = ow.worldToGrid(pc.selection_start)
				if ow.grid.has(selection_start_grid_pos):
					# Get a reference to the CellArea, through the CellData. Do not store CellData (linked in CellArea)
					var selected_cell_area: CellArea = ow.grid[ow.worldToGrid(pc.selection_start)].cell_area
					if selected_cell_area.collision_layer == Constants.layer_mapping[current_cell_select_mode]:
						if selected_cell_area is CellArea:
							# This and the elif below have a similar relationship and function to on_area_entered/exited
							if not selected_cell_area.is_selected:
								# TODO: This needs to support unit selection as well
								if selected_cell_area.cell_data.occupier: # Only select cells with occupiers
									selected_cell_area.is_selected = true
									selected_cell_area_array.append(selected_cell_area)
									selected_cell_area.cell_select_box.sprite.visible = true
									update_cell_select_gui_data()
									cell_area_selection_changed.emit()

							# If a cell is already selected and shift clicked, deselect it
							elif selected_cell_area.is_selected and Input.is_action_pressed("shift"):
								release_specific_cell_area(selected_cell_area)
								update_cell_select_gui_data()
								cell_area_selection_changed.emit()
								# Don't continue and turn on select panel, it will just readd the cell that was just released
								return

				# Handle select panel selection. This allows _process to start tracking the mouse
				pc.is_selecting = true
				pc.select_panel_collision.disabled = false
				pc.select_panel.position = pc.selection_start
				pc.select_panel.size = Vector2()
				pc.select_panel.visible = true # This may have been hidden by double click
				pc.select_panel_collision.position = pc.selection_start
				pc.select_panel_collision.shape.size = Vector2()
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				reset_select_panel_release_selected_cell_areas()
				update_cell_select_gui_data()
				cell_area_selection_changed.emit()

func on_cell_select_panel_area_entered(entering_cell_area):
	if entering_cell_area is CellArea:
		if not entering_cell_area.is_selected: # Check if already selected ? 
			entering_cell_area.preserve = false
			selected_cell_area_array.append(entering_cell_area)
			entering_cell_area.is_selected = true
			entering_cell_area.cell_select_box.sprite.visible = true

func on_cell_select_panel_area_exited(exiting_cell_area):
	# Only process if intruder is CellArea type, clear selected var and make cell_select_box invisible
	if exiting_cell_area is CellArea:
		if exiting_cell_area.is_selected:
			if not exiting_cell_area.preserve:
				release_specific_cell_area(exiting_cell_area)

func reset_select_panel_preserve_selected_cell_areas():
	pc.is_selecting = false
	preserve_selected_cell_areas()
	pc.select_panel.size = Vector2()
	pc.select_panel_collision.disabled = true
	pc.select_panel_collision.shape.size = Vector2()

func preserve_selected_cell_areas() -> void:
	for cell_area in selected_cell_area_array:
		cell_area.preserve = true

func reset_select_panel_release_selected_cell_areas():
	pc.is_selecting = false
	release_selected_cell_areas()
	pc.select_panel.size = Vector2()
	pc.select_panel_collision.disabled = true
	pc.select_panel_collision.shape.size = Vector2()
	selected_cell_area_array.clear()

func release_selected_cell_areas() -> void:
	for cell_area in selected_cell_area_array:
		cell_area.preserve = false
		cell_area.is_selected = false
		cell_area.cell_select_box.sprite.visible = false
	selected_cell_area_array.clear()

func release_specific_cell_area(selected_cell_area) -> void:
	selected_cell_area.preserve = false
	selected_cell_area.is_selected = false
	selected_cell_area.cell_select_box.sprite.visible = false
	var index = selected_cell_area_array.find(selected_cell_area)
	selected_cell_area_array.remove_at(index)

func on_cell_select_mode_changed(new_cell_select_mode: String) -> void:
	current_cell_select_mode = new_cell_select_mode
	pc.select_panel_area.collision_mask = Constants.layer_mapping[current_cell_select_mode]
	reset_select_panel_release_selected_cell_areas()


## Update data that cell_select_gui uses to display inspector data. Does NOT handle emitting collision detection signals
func update_cell_select_gui_data() -> void:
	# TODO:  This assumes that each CellArea's CellData has an occupier. Could be an issue in the future
	# Will need more logic based on select mode
	is_selected_cell_area_array_homogenous = is_selected_cell_area_array_one_occupier_name(selected_cell_area_array)
	if is_selected_cell_area_array_homogenous:
		if selected_cell_area_array.size() > 0:
			selected_cell_area_array_inspector_name = selected_cell_area_array[0].cell_data.occupier.inspector_name
		else:
			selected_cell_area_array_inspector_name = ""

## Check that the occupier objects of all CellData objects in the array have the same 'cname' value. 
## Returns false if `array` is empty
func is_selected_cell_area_array_one_occupier_name(array) -> bool:
	if array.size() > 0:
		var match_cname = array[0].cell_data.occupier.cname
		for cell_area in array.slice(1,array.size()):
			var curr_cname = cell_area.cell_data.occupier.cname
			if not (curr_cname == match_cname):
				return false
	else:
		return false
	return true
