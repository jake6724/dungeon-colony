class_name HUD
extends Control

# Scene node references
@onready var main = get_tree().root.get_node("Main")
@onready var pc: PlayerController = main.get_node("PlayerController")

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

func _ready():
	# Connect to PlayerController signals
	pc.cell_area_selection_changed.connect(update_inspector_label)

	# Connect to select mode signals
	chop_wood_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("tree"))
	mine_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("mineral"))
	harvest_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("plant"))
	structure_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("structure"))
	item_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("item"))
	unit_button.focus_entered.connect(on_select_mode_button_focus_entered.bind("unit"))


func on_select_mode_button_focus_entered(new_select_mode: String):
	select_mode_changed.emit(new_select_mode)

func set_inspector_name_label_text(new_text) -> void:
	inspector_name_label.text = new_text

## Update inspector label based on data from PlayerController. Should only be updated when PC's 
## `area_entered` or `area_exited` signals are emitted.
func update_inspector_label() -> void:
	if pc.selected_cell_area_array.size() > 0:
		if pc.is_selected_cell_area_array_homogenous:
			set_inspector_name_label_text(pc.selected_cell_area_array_inspector_name + " x" + str(pc.selected_cell_area_array.size()))
		else:
			set_inspector_name_label_text("Multiple objects selected")
	else:
		set_inspector_name_label_text("")
