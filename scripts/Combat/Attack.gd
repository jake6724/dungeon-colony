class_name Attack
extends Object

var attacker: Unit
var receiver: Unit
var weapon_damage: float
var magic_damage: float
var weapon_damage_type: Constants.WeaponDamageType
var magic_damage_type: Constants.MagicDamageType

func _init(
	_attacker: Unit, 
	_receiver: Unit, 
	_weapon_damage: float = 0,  
	_weapon_damage_type: Constants.WeaponDamageType = Constants.WeaponDamageType.NONE, 
	_magic_damage: float = 0,
	_magic_damage_type: Constants.MagicDamageType = Constants.MagicDamageType.NONE,):
	
	attacker = _attacker
	receiver = _receiver
	weapon_damage = _weapon_damage
	weapon_damage_type = _weapon_damage_type
	magic_damage = _magic_damage
	magic_damage_type = _magic_damage_type

func console_log() -> void:
	print("===========================================================================")
	print("New attack created")
	print("Attacker: ", attacker)
	print("receiver: ", receiver)
	print("Weapon Damage: ", weapon_damage)
	print("Weapon Damage Type: ", weapon_damage_type)
	print("Magic Damage: ", magic_damage)
	print("Magic Damage Type: ", magic_damage_type)
	print("===========================================================================")