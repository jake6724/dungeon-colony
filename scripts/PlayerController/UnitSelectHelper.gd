extends Node

func on_target_area_entered(entering_target):
	if entering_target.owner is EnemyUnit:
		current_target = entering_target.owner

func on_target_area_exited(exiting_target):
	if exiting_target.owner is EnemyUnit:
		if current_target:
			current_target = null

unc select_unit(new_unit) -> void:
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
func reset_target_lines_set_selected_target() -> void:
	is_selecting_target = false
	for unit in selected_units_array:
		unit.target = current_target
		if unit.target_line:
			unit.target_line.points = PackedVector2Array([])
	# Reset target area
	target_area.position = Vector2()
	target_collision.disabled = true

func reset_target_lines() -> void:
	is_selecting_target = false
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
	is_selecting_target = true
	target_collision.disabled = false

	# Configure data for newly selected unit
	var unit: PlayerUnit = all_player_units_array[current_unit_index]
	unit.preserve = false # Preservation has been used up to get here (or may already be false)
	selected_units_array.append(unit)
	unit.is_selected = true
	unit.selected_sprite.visible = true
	initialize_target_line(unit)
	set_unit_target_line_to_mouse_position(unit)
	
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
	new_target_line.points = PackedVector2Array([unit.position])
	unit.target_line = new_target_line
	add_child(new_target_line) # Make child of PlayerController for now, so we don't have to worry about transform of unit

func set_unit_target_line_to_mouse_position(unit) -> void:
	current_mouse_position = get_global_mouse_position()
	var new_vector_magnitude = (current_mouse_position - unit.position).length()
	if new_vector_magnitude < unit.max_range.length():
		unit.target_line.points = PackedVector2Array([unit.position, current_mouse_position])
		target_area.position = current_mouse_position
	else:
		var direction_vector = current_mouse_position - unit.position
		var scaling_factor = unit.max_range.length() / direction_vector.length()
		var scaled_vector = direction_vector * scaling_factor
		var bounded_vector = scaled_vector + unit.position
		unit.target_line.points = PackedVector2Array([unit.position, bounded_vector])
		target_area.position = bounded_vector