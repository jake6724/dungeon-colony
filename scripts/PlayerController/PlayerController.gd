class_name PlayerController
extends Node2D

################################################################
# TODOs
# 3. Double clicking should only select everything if you clicked a valid object, and then reset what
#		that object was when you're done

# Scene Node references 
@onready var main = get_tree().root.get_node("Main")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var ui = main.get_node("CanvasLayer").get_node("UI")
@onready var hud: HUD = ui.get_node("HUD")
@onready var camera: Camera2D = main.get_node("Camera2D")

# Children references 
@onready var select_panel: Panel = $SelectPanel
@onready var select_panel_area: Area2D = $SelectPanelArea
@onready var select_panel_collision: CollisionShape2D = $SelectPanelArea/SelectPanelCollision
@onready var select_panel_collision_shape: Shape2D = select_panel_collision.shape

# Signals 
signal cell_area_selection_changed

# Cell selection data
var selected_cell_area_array: Array[CellArea] = []
var selection_start: Vector2
var current_mouse_position: Vector2
var selection_rect: Rect2
var is_selecting: bool

# HUD update data
var is_selected_cell_area_array_homogenous: bool
var selected_cell_area_array_inspector_name: String

# Select mode data
var current_select_mode: String = "unit_item"

# idk
var is_input_enabled: bool = true

func _ready():
	select_panel_area.area_entered.connect(on_select_panel_area_entered)
	select_panel_area.area_exited.connect(on_select_panel_area_exited)
	select_panel_collision.disabled = true
	select_panel_area.collision_layer = Constants.layer_mapping["no_collision"]
	select_panel_area.collision_mask = Constants.layer_mapping[current_select_mode]

	# Connect to HUD select mode signals
	hud.select_mode_changed.connect(on_select_mode_changed)
	hud.mouse_entered_hud.connect(on_mouse_entered_hud)
	hud.mouse_exited_hud.connect(on_mouse_exited_hud)

func _process(_delta):
	if is_selecting:
		# Continuously update the selection rectangle to match the mouse position
		# select_panel and select_panel_area are set to match this rectangle, it does not interact with cells
		current_mouse_position = get_global_mouse_position()
		selection_rect = Rect2(selection_start, current_mouse_position - selection_start).abs()

		if selection_rect.size > Vector2(1,1):
			# Select panel is a visual indicator for player. 
			# select_panel_area and collision actually detect cell area collisions
			select_panel.position = selection_rect.position
			select_panel.size = selection_rect.size

			select_panel_collision.position = selection_rect.position + (selection_rect.size / 2) # scales out from center for some reason
			select_panel_collision.shape.size = selection_rect.size

func _input(event):
	if is_input_enabled:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_action_just_released("left_click"):
				reset_select_panel_preserve_selected()
				update_hud_data()
				cell_area_selection_changed.emit()
				return

			# Handle double clicking
			# TODO: Double clicking shouldn't care about select mode; instead it should just select
			# every cell_area that has the same occupier cname(?) as the object that was just double clicked
			if event.double_click:
				select_panel.visible = false
				select_panel_collision.disabled = false

				var new_size = Vector2((get_viewport().size)) / camera.zoom
				var new_position = camera.position - (new_size / 2)

				select_panel.size = new_size
				select_panel.position = new_position

				select_panel_collision.shape.size = new_size
				select_panel_collision.position = new_position + (new_size / 2)
				return # Do not continue to process input
			
			if event.pressed:
				# Only reset previously selected data if shift is not held during current click
				if not(Input.is_action_pressed("shift")):
					release_selected()

				# Handle individual cell selection
				# TODO: This needs to take into account the select mode
				selection_start = get_global_mouse_position()
				var selection_start_grid_pos = ow.worldToGrid(selection_start)
				if ow.grid.has(selection_start_grid_pos):
					# Get a reference to the CellArea, through the CellData. Do not store CellData (linked in CellArea)
					var selected_cell_area: CellArea = ow.grid[ow.worldToGrid(selection_start)].cell_area
					if selected_cell_area.collision_layer == Constants.layer_mapping[current_select_mode]:
						if selected_cell_area is CellArea:
							# This and the elif below have a similar relationship and function to on_area_entered/exited
							if not selected_cell_area.is_selected:
								# TODO: This needs to support unit selection as well
								if selected_cell_area.cell_data.occupier: # Only select cells with occupiers
									selected_cell_area.is_selected = true
									selected_cell_area_array.append(selected_cell_area)
									selected_cell_area.cell_select_box.sprite.visible = true
									update_hud_data()
									cell_area_selection_changed.emit()
									

							# If a cell is already selected and shift clicked, deselect it
							elif selected_cell_area.is_selected and Input.is_action_pressed("shift"):
								release_specific_cell_area(selected_cell_area)
								update_hud_data()
								cell_area_selection_changed.emit()
								# Don't continue and turn on select panel, it will just readd the cell that was just released
								return

				# Handle select panel selection. This allows _process to start tracking the mouse
				is_selecting = true
				select_panel_collision.disabled = false
				select_panel.position = selection_start
				select_panel.size = Vector2()
				select_panel.visible = true # This may have been hidden by double click
				select_panel_collision.position = selection_start
				select_panel_collision.shape.size = Vector2()
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				reset_select_panel_release_selected()
				update_hud_data()
				cell_area_selection_changed.emit()

func on_select_mode_changed(new_select_mode: String) -> void:
	current_select_mode = new_select_mode
	select_panel_area.collision_mask = Constants.layer_mapping[current_select_mode]
	reset_select_panel_release_selected()

func on_select_panel_area_entered(entering_cell_area):
	if entering_cell_area is CellArea:
		if not entering_cell_area.is_selected: # Check if already selected ? 
			entering_cell_area.preserve = false
			selected_cell_area_array.append(entering_cell_area)
			entering_cell_area.is_selected = true
			entering_cell_area.cell_select_box.sprite.visible = true

func on_select_panel_area_exited(exiting_cell_area):
	# Only process if intruder is CellArea type, clear selected var and make cell_select_box invisible
	if exiting_cell_area is CellArea:
		if exiting_cell_area.is_selected:
			if not exiting_cell_area.preserve:
				release_specific_cell_area(exiting_cell_area)

func reset_select_panel_preserve_selected():
	is_selecting = false
	preserve_selected_cell_areas()
	select_panel.size = Vector2()
	select_panel_collision.disabled = true
	select_panel_collision.shape.size = Vector2()

func preserve_selected_cell_areas() -> void:
	for cell_area in selected_cell_area_array:
		cell_area.preserve = true

func reset_select_panel_release_selected():
	is_selecting = false
	release_selected()
	select_panel.size = Vector2()
	select_panel_collision.disabled = true
	select_panel_collision.shape.size = Vector2()
	clear_selected_cell_area_array()

func release_selected() -> void:
	for cell_area in selected_cell_area_array:
		cell_area.preserve = false
		cell_area.is_selected = false
		cell_area.cell_select_box.sprite.visible = false

	clear_selected_cell_area_array()

func release_specific_cell_area(selected_cell_area) -> void:
	selected_cell_area.preserve = false
	selected_cell_area.is_selected = false
	selected_cell_area.cell_select_box.sprite.visible = false
	var index = selected_cell_area_array.find(selected_cell_area)
	selected_cell_area_array.remove_at(index)

func clear_selected_cell_area_array() -> void:
	selected_cell_area_array.clear()

## Update data that HUD uses to display inspector data. Does NOT handle emitting collision detection signals
func update_hud_data() -> void:
	# TODO:  This assumes that each CellArea's CellData has an occupier. Could be an issue in the future
	# Will need more logic based on select mode
	is_selected_cell_area_array_homogenous = is_array_one_occupier_name(selected_cell_area_array)
	if is_selected_cell_area_array_homogenous:
		if selected_cell_area_array.size() > 0:
			selected_cell_area_array_inspector_name = selected_cell_area_array[0].cell_data.occupier.inspector_name
		else:
			selected_cell_area_array_inspector_name = ""

func on_mouse_entered_hud() -> void:
	if not is_selecting:
		is_input_enabled = false

func on_mouse_exited_hud() -> void:
	is_input_enabled = true

## Check that the occupier objects of all CellData objects in the array have the same 'cname' value. 
## Returns false if `array` is empty
func is_array_one_occupier_name(array) -> bool:
	if array.size() > 0:
		var match_cname = array[0].cell_data.occupier.cname
		for cell_area in array.slice(1,array.size()):
			var curr_cname = cell_area.cell_data.occupier.cname
			if not (curr_cname == match_cname):
				return false
	else:
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
