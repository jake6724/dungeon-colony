class_name WeaponData
extends Resource

@export var name: String = ""
@export var display_name: String = ""
@export var type: Constants.WeaponType = Constants.WeaponType.NONE
@export var damage_type: Constants.WeaponDamageType = Constants.WeaponDamageType.NONE 
@export var damage: float = 0.0
@export var attack_speed: float = 1.0 # The base speed, in seconds. Reduced by weapon level, and modified by armor (plus or minus)
@export var move_speed_modifier: float = 1.0