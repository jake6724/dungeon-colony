class_name HUD
extends Control

@onready var inspector: Control = $Inspector
@onready var inspector_name_label: Label = $Inspector/InspectorNameLabel
@onready var select_panel: Panel = $SelectPanel

func set_inspector_name_label_text(new_text) -> void:
	inspector_name_label.text = new_text
