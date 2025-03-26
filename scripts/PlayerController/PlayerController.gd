class_name PlayerController
extends Node2D

# TODO: 
# 1. When swapping select modes, reset all the data from the current one. 
# 	so each select mode type should have a function to initialize data when you enter it, and a 
# 	a function to clear data when you leave it

# Scene Node references 
@onready var main = get_tree().root.get_node("Main")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var gui = get_node("GUI")
@onready var camera: Camera2D = main.get_node("Camera2D")
@onready var cell_select_gui: CellSelectGUI = gui.get_node("CellSelectGUI")
@onready var unit_combat_gui: UnitCombatGUI = gui.get_node("UnitCombatGUI")

# Children references 
@onready var select_panel: Panel = $SelectPanel
@onready var select_panel_area: Area2D = $SelectPanelArea
@onready var select_panel_collision: CollisionShape2D = $SelectPanelArea/SelectPanelCollision
@onready var select_panel_collision_shape: Shape2D = select_panel_collision.shape
@onready var cell_select: CellSelect = $SelectModes/CellSelect
@onready var unit_combat_select: UnitCombatSelect = $SelectModes/UnitCombatSelect

# Selection data relevant to multiple select modes
var is_selecting: bool
var selection_start: Vector2
var current_mouse_position: Vector2
var select_rect: Rect2
var select_rect_minimum_size = Vector2(30,30)
var is_input_enabled: bool = true # Disabled when mouse enters a GUI component

# Top-level selection info
enum select_modes {CELL_SELECT, UNIT_COMBAT_SELECT}
var current_select_mode = select_modes.CELL_SELECT

func _ready():
	match current_select_mode:
		select_modes.CELL_SELECT:
			cell_select.cell_select_ready()
			unit_combat_gui.visible = false

func _process(_delta):
	match current_select_mode:
		select_modes.CELL_SELECT:
			cell_select.cell_select_process()

		select_modes.UNIT_COMBAT_SELECT:
			unit_combat_select.unit_combat_select_process()

func _input(event):
	# Change selection mode and stop processing. This will also need to work thru GUI
	if Input.is_action_just_pressed("x"):
		
		# Switch to Unit Combat Select
		if current_select_mode == select_modes.CELL_SELECT:
			current_select_mode = select_modes.UNIT_COMBAT_SELECT
			cell_select_gui.visible = false
			unit_combat_gui.visible = true
			unit_combat_select.unit_combat_configure_select_mode()
			on_switch_selected_mode()

		# Switch to Cell Select
		elif current_select_mode == select_modes.UNIT_COMBAT_SELECT:
			current_select_mode = select_modes.CELL_SELECT
			cell_select_gui.visible = true
			unit_combat_gui.visible = false
			on_switch_selected_mode()
		return

	match current_select_mode:
		select_modes.CELL_SELECT:
			cell_select.cell_select_input(event)
		
		select_modes.UNIT_COMBAT_SELECT:
			unit_combat_select.unit_combat_select_input(event)

func on_select_panel_area_entered(entering_cell_area):
	match current_select_mode:
		select_modes.CELL_SELECT:
			cell_select.on_cell_select_panel_area_entered(entering_cell_area)
		
		select_modes.UNIT_COMBAT_SELECT:
			unit_combat_select.on_unit_combat_select_panel_area_entered(entering_cell_area)

func on_select_panel_area_exited(exiting_cell_area):
	match current_select_mode:
		select_modes.CELL_SELECT:
			cell_select.on_cell_select_panel_area_exited(exiting_cell_area)
		
		select_modes.UNIT_COMBAT_SELECT:
			unit_combat_select.on_unit_combat_select_panel_area_exited(exiting_cell_area)

func reset_select_panel():
	is_selecting = false
	select_panel.size = Vector2()
	select_panel_collision.disabled = true
	select_panel_collision.shape.size = Vector2()

## Handle reseting data when switching to a new select mode
func on_switch_selected_mode() -> void:
	cell_select.reset_select_panel_release_selected_cell_areas()

func on_mouse_entered_gui() -> void:
	if not is_selecting:
		is_input_enabled = false

func on_mouse_exited_gui() -> void:
	is_input_enabled = true
