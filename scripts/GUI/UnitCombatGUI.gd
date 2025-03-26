class_name UnitCombatGUI
extends Control

# Node References
@onready var main = get_tree().root.get_node("Main")
@onready var pc: PlayerController = main.get_node("PlayerController")
@onready var unit_combat_select: UnitCombatSelect = pc.get_node("SelectModes").get_node("UnitCombatSelect")

# Child References
@onready var abilities:HBoxContainer = $UnitAbilities
@onready var ability_button_1: Button = $UnitAbilities/Ability1Button
@onready var ability_button_2: Button = $UnitAbilities/Ability2Button
@onready var ability_button_3: Button = $UnitAbilities/Ability3Button
@onready var ability_button_4: Button = $UnitAbilities/Ability4Button
var ability_buttons_array: Array[Button]

signal mouse_entered_gui

func _ready():
	ability_buttons_array = [ability_button_1, ability_button_2, ability_button_3, ability_button_4]
	unit_combat_select.unit_combat_selection_changed.connect(on_unit_combat_selection_changed)
	abilities.visible = false

func on_unit_combat_selection_changed():
	reset_ability_buttons_text()
	if unit_combat_select.selected_units_array.size() > 0:
		abilities.visible = true
		update_ability_buttons_text()
	else:
		abilities.visible = false

func update_ability_buttons_text():
	if unit_combat_select.selected_units_array.size() == 1:
		for i in range(unit_combat_select.selected_units_array[0].abilities_array.size()):
			ability_buttons_array[i].text = unit_combat_select.selected_units_array[0].abilities_array[i].display_name
	elif unit_combat_select.selected_units_common_abilities_array.size() > 0: 
		for i in range(unit_combat_select.selected_units_common_abilities_array.size()):
			ability_buttons_array[i].text = unit_combat_select.selected_units_common_abilities_array[i].display_name

func reset_ability_buttons_text():
	for button in ability_buttons_array:
		button.text = ""

func on_mouse_entered_gui():
	mouse_entered_gui.emit()
