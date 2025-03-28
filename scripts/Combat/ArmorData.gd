class_name ArmorData
extends Resource

@export var name = ""
@export var display_name = ""
@export var type: Constants.ArmorType = Constants.ArmorType.NONE
@export var damage_buff: float = 0.0
@export var magic_buff: float = 0.0
@export var defense: float = 0.0
@export var move_speed_modifier: float = 0.0
@export var is_broken: bool = false

# [-1.0 to 1.0]; Value is a percentage of total character attack speed add or subtracted (.1 is +%10 attack speed)
@export var attack_speed_modifer: float = 0.0 

@export var hitpoints: float = 0.0