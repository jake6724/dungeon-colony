class_name UnitCombatSelect
extends Node2D

# Node References
@onready var main = get_tree().root.get_node("Main")
@onready var pc: PlayerController = main.get_node("PlayerController")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var gui: Node = pc.get_node("GUI")
@onready var unit_combat_gui: UnitCombatGUI = gui.get_node("UnitCombatGUI")

# Unit combat selection data
@onready var units = main.get_node("PlayerUnits")
@onready var target_area: Area2D = pc.get_node("TargetArea")
@onready var target_collision: CollisionShape2D = target_area.get_node("TargetCollision")

# TODO organize all this
var selected_units_array: Array[PlayerUnit] = [] 
var all_player_units_array: Array[PlayerUnit]
var current_unit_index: int = 0
var is_targeting: bool = false
var target_line_start: Vector2 # This needs to eventually be and array and start from the center of all selected units
var target_distance_min: Vector2 = Vector2(50,50)
var current_target: EnemyUnit
var dash_line: Resource = preload("res://art/unit_combat/dash_line.png")

var selected_units_common_abilities_array: Array[AbilityData] = []
var active_ability: AbilityData = null

# Signals
signal unit_combat_selection_changed

func _ready():
	connect_to_gui_signals()
	target_area.area_entered.connect(on_target_area_entered)
	target_area.area_exited.connect(on_target_area_exited)
	target_area.collision_layer = Constants.layer_mapping["no_collision"]
	target_area.collision_mask = Constants.layer_mapping["enemy_unit"]

## Called everytime PlayerController switches to this select mode
func configure_select_mode():
	selected_units_array = []
	is_targeting = false
	pc.select_panel_area.collision_mask = Constants.layer_mapping["unit"]

func unit_combat_select_process():
	# Unit target select and graphics
	if is_targeting:
		var new_current_mouse_position = get_global_mouse_position()
		if new_current_mouse_position != pc.current_mouse_position: # Only do all the calculations if mouse position changed
			pc.current_mouse_position = new_current_mouse_position
			set_selected_units_target_lines()

	if pc.is_selecting:
		pc.current_mouse_position = get_global_mouse_position()
		# Continuously update the selection rectangle to match the mouse position
		# select_panel and select_panel_area are set to match this rectangle, it does not interact with cells
		pc.select_rect = Rect2(pc.selection_start, pc.current_mouse_position - pc.selection_start).abs()

		if pc.select_rect.size > pc.select_rect_minimum_size:
			# Select panel is a visual indicator for player. 
			# select_panel_area and collision actually detect cell area collisions
			pc.select_panel.position = pc.select_rect.position
			pc.select_panel.size = pc.select_rect.size

			pc.select_panel_collision.position = pc.select_rect.position + (pc.select_rect.size / 2) # scales out from center for some reason
			pc.select_panel_collision.shape.size = pc.select_rect.size

func unit_combat_select_input(event):
	if Input.is_action_just_pressed("tab"):
		tab_select_next_unit()

	if Input.is_action_just_pressed("shift"):
		# stop targeting, go back to selection
		is_targeting = false
		reset_target_lines() # this will reset is_targeting as well

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if pc.is_input_enabled:
			# left-click RELEASE
			if Input.is_action_just_released("left_click"):
				if Input.is_action_pressed("shift"):
					preserve_selected_units()

				# Units have been selected, but not already in target select mode
				# Draw target lines and change to target selection mode
				if not is_targeting and selected_units_array.size() > 0: 
					# Reset selection data and enable target detection
					is_targeting = true
					reset_select_panel_preserve_selected_units()
					target_collision.disabled = false
					for unit in selected_units_array:
						initialize_target_line(unit)
				else:
					# Releasing left-click but nothing has been selected
					pc.reset_select_panel()

			# Left-click press
			if Input.is_action_just_pressed("left_click"):
				# If we left click while selecting target, we don't need to worry about resetting selected
				# This is handled below by 'if not(Input.is_action_pressed("shift")):release_all_selected_units()'
				if is_targeting: reset_target_lines()
				if not(Input.is_action_pressed("shift")) and selected_units_array.size() > 0:
					release_all_selected_units()
					update_gui_data()
					unit_combat_selection_changed.emit()

				# Handle select panel selection. This allows _process to start tracking the mouse
				pc.is_selecting = true
				pc.selection_start = get_global_mouse_position()
				pc.select_panel_collision.disabled = false
				pc.select_panel.position = pc.selection_start
				pc.select_panel.size = Vector2()
				pc.select_panel.visible = true # Incase this was previously hidden by double click
				pc.select_panel_collision.position = pc.selection_start
				pc.select_panel_collision.shape.size = Vector2()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if Input.is_action_just_pressed("right_click"):
			if is_targeting: # If targeting, we need to determine if a valid target was clicked
				if current_target:
					set_selected_target()
					reset_target_lines()
					pc.reset_select_panel()
				else:
					set_selected_unit_paths()
					# reset_target_lines()
			else: # If not targeting, we only want to set pathing
				set_selected_unit_paths()

func on_unit_combat_select_panel_area_entered(entering_area):
	if entering_area.owner is PlayerUnit:
		var entering_player_unit = entering_area.owner
		# Get the parent PlayerUnit of the area
		if not entering_player_unit.is_selected:
			select_unit(entering_player_unit)

		# Shift-click deselecting
		# We want to make sure that the select panel isn't being used for multi-select, hence the size requirement
		elif entering_player_unit.is_selected and Input.is_action_pressed("shift") and pc.select_panel_collision.shape.size < Vector2(60,60):
			release_specific_unit(entering_player_unit)
		
		update_gui_data()
		unit_combat_selection_changed.emit()


## Called when an Area2D that was in select_panel leaves the select_panel borders. 
## Only used in the case of units exiting select panel before final size is set
func on_unit_combat_select_panel_area_exited(exiting_area):
	if exiting_area.owner is PlayerUnit:
		var old_unit = exiting_area.get_parent()
		if old_unit.is_selected:
			if not old_unit.preserve:
				release_specific_unit(old_unit)
				update_gui_data()
				unit_combat_selection_changed.emit()

func on_target_area_entered(entering_target):
	print(entering_target)
	if entering_target.owner is EnemyUnit:
		var entering_enemy: EnemyUnit = entering_target.owner
		print("Found!")
		current_target = entering_enemy

func on_target_area_exited(exiting_target):
	if exiting_target.owner is EnemyUnit:
		if current_target:
			current_target = null

func reset_select_panel_preserve_selected_units():
	preserve_selected_units()
	pc.reset_select_panel()

func preserve_selected_units() -> void:
	for unit in selected_units_array:
		unit.preserve = true

func reset_select_panel_release_all_selected_units():
	release_all_selected_units()
	pc.reset_select_panel()

func release_all_selected_units() -> void:
	for unit in selected_units_array:
		unit.preserve = false
		unit.is_selected = false
		unit.selected_sprite.visible = false
	selected_units_array.clear()

func select_unit(new_unit) -> void:
	new_unit.preserve = false # Preservation has been used up to get here (or may already be false)
	selected_units_array.append(new_unit)
	new_unit.is_selected = true
	new_unit.selected_sprite.visible = true

func release_specific_unit(selected_unit) -> void:
	selected_unit.preserve = false
	selected_unit.is_selected = false
	selected_unit.selected_sprite.visible = false
	var index = selected_units_array.find(selected_unit)
	selected_units_array.remove_at(index)

## This is the final step in targeting, and ends targeting mode. Selected units will set their target, 
## and remove targeting lines, and clear `selected_units_array` to start fresh. 
func set_selected_target() -> void:
	is_targeting = false
	print(current_target)
	for unit in selected_units_array:
		unit.target = current_target
	# Reset target area
	target_area.position = Vector2()
	target_collision.disabled = true

func reset_target_lines() -> void:
	is_targeting = false
	for unit in selected_units_array:
		if unit.target_line:
			unit.target_line.points = PackedVector2Array([])
	# Reset target area
	target_area.position = Vector2()
	target_collision.disabled = true

func get_all_player_units() -> Array[PlayerUnit]:
	for unit in units.get_children():
		if unit is PlayerUnit:
			all_player_units_array.append(unit)
	return all_player_units_array

func tab_select_next_unit() -> void:
	# Clear data from previous tab selection
	reset_target_lines()
	release_all_selected_units()

	# Configure controller data
	is_targeting = true
	target_collision.disabled = false

	# Configure data for newly selected unit
	var unit: PlayerUnit = all_player_units_array[current_unit_index]
	unit.preserve = false # Preservation has been used up to get here (or may already be false)
	selected_units_array.append(unit)
	unit.is_selected = true
	unit.selected_sprite.visible = true
	initialize_target_line(unit)
	set_selected_units_target_lines()
	
	# Update index for the next time tab select is called
	if current_unit_index != (all_player_units_array.size() - 1):
		current_unit_index += 1 
	else:
		current_unit_index = 0

func initialize_target_line(unit) -> void:
	var new_target_line: Line2D = Line2D.new()
	new_target_line.texture = dash_line
	new_target_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	new_target_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	new_target_line.points = PackedVector2Array([unit.center])
	new_target_line.z_index = Constants.z_index_mapping["GUI"] # TODO Make its own
	unit.target_line = new_target_line
	pc.add_child(new_target_line) # Make child of PlayerController for now, so we don't have to worry about transform of unit

func set_selected_units_target_lines() -> void:
	for unit in selected_units_array:
		if not unit.is_moving:
			var new_vector_magnitude = (pc.current_mouse_position - unit.position).length()
			if new_vector_magnitude < unit.max_range.length():
				unit.target_line.points = PackedVector2Array([unit.position, pc.current_mouse_position])
				target_area.position = pc.current_mouse_position
			else:
				var direction_vector = pc.current_mouse_position - unit.position
				var scaling_factor = unit.max_range.length() / direction_vector.length()
				var scaled_vector = direction_vector * scaling_factor
				var bounded_vector = scaled_vector + unit.position
				unit.target_line.points = PackedVector2Array([unit.position, bounded_vector])
				target_area.position = bounded_vector
		elif unit.is_moving: # Don't draw targeting line if unit is moving
			unit.target_line.points = PackedVector2Array()

func set_selected_unit_paths():
	var target_grid_point = Constants.world_to_grid(pc.current_mouse_position)
	for unit in selected_units_array:
		unit.set_path_to(target_grid_point)
	pass

## Reset and update `selected_units_common_abilities_array` to only include `AbilityData` resources which are present
## in all units found in `selected_units_array`.
func set_common_unit_abilities():
	selected_units_common_abilities_array.clear()
	var abilities_table: Dictionary = {}
	for unit in selected_units_array:
		for ability in unit.abilities_array:
			if abilities_table.has(ability):
				abilities_table[ability] += 1
			else:
				abilities_table[ability] = 1
	for ability in abilities_table.keys():
		if abilities_table[ability] == selected_units_array.size():
			selected_units_common_abilities_array.append(ability)

## Update data that unit_combat_gui uses. Does NOT handle emitting collision detection signals
func update_gui_data() -> void:
	set_common_unit_abilities()

func connect_to_gui_signals():
	for button in unit_combat_gui.ability_buttons_array:
		button.mouse_entered.connect(pc.on_mouse_entered_gui)
		button.mouse_exited.connect(pc.on_mouse_exited_gui)
