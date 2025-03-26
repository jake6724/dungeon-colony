class_name CellSelectGUI
extends Control

# Scene node references
@onready var main = get_tree().root.get_node("Main")
@onready var pc: PlayerController = main.get_node("PlayerController")
@onready var cell_select: CellSelect = pc.get_node("SelectModes").get_node("CellSelect")

# Children references
# Inspector
@onready var inspector: Control = $Inspector
@onready var inspector_name_label: Label = $Inspector/InspectorNameLabel
# Select Mode
@onready var select_mode_container: HBoxContainer = $SelectModeContainer
@onready var chop_wood_button: Button = $SelectModeContainer/ChopWoodButton
@onready var mine_button: Button = $SelectModeContainer/MineButton
@onready var harvest_button: Button = $SelectModeContainer/HarvestButton
@onready var structure_button: Button = $SelectModeContainer/StructureButton
@onready var item_button: Button = $SelectModeContainer/ItemButton
@onready var unit_button: Button = $SelectModeContainer/UnitButton

# Signals
signal select_mode_changed
signal mouse_entered_cell_select_gui
signal mouse_exited_cell_select_gui

func _ready():
	# Connect to PlayerController signals
	cell_select.cell_area_selection_changed.connect(update_inspector_label)

	select_mode_container.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	select_mode_container.mouse_exited.connect(on_mouse_exited_cell_select_gui)

	# Connect to select mode signals
	chop_wood_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("tree"))
	mine_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("mineral"))
	harvest_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("plant"))
	structure_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("structure"))
	item_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("item"))
	unit_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("unit"))

	# Connect to mouse_entered signals
	# TODO: This sucks
	chop_wood_button.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	chop_wood_button.mouse_exited.connect(on_mouse_exited_cell_select_gui)
	mine_button.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	mine_button.mouse_exited.connect(on_mouse_exited_cell_select_gui)
	harvest_button.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	harvest_button.mouse_exited.connect(on_mouse_exited_cell_select_gui)
	structure_button.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	structure_button.mouse_exited.connect(on_mouse_exited_cell_select_gui)
	item_button.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	item_button.mouse_exited.connect(on_mouse_exited_cell_select_gui)
	unit_button.mouse_entered.connect(on_mouse_entered_cell_select_gui)
	unit_button.mouse_exited.connect(on_mouse_exited_cell_select_gui)


func on_select_mode_button_focus_entered(new_select_mode: String):
	select_mode_changed.emit(new_select_mode)

func set_inspector_name_label_text(new_text) -> void:
	inspector_name_label.text = new_text

## Update inspector label based on data from PlayerController. Should only be updated when PC's 
## `area_entered` or `area_exited` signals are emitted.
func update_inspector_label() -> void:
	if cell_select.selected_cell_area_array.size() > 0:
		if cell_select.is_selected_cell_area_array_homogenous:
			set_inspector_name_label_text(cell_select.selected_cell_area_array_inspector_name + " x" + str(cell_select.selected_cell_area_array.size()))
		else:
			set_inspector_name_label_text("Multiple objects selected")
	else:
		set_inspector_name_label_text("")

func on_mouse_entered_cell_select_gui():
	mouse_entered_cell_select_gui.emit()

func on_mouse_exited_cell_select_gui():
	mouse_exited_cell_select_gui.emit()
