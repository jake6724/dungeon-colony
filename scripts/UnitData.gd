class_name UnitData
extends Object # Not a resource cause we just want to make new ones at runtime randomly. Not like an ability where they are pre-defined 

# General
var name: String = ""
var is_player_unit = true

# Jobs
var job_levels: Dictionary[Constants.JobType, float] = {
	Constants.JobType.CARPENTER: 0.0,
	Constants.JobType.STONEWORKER: 0.0,
	Constants.JobType.BLACKSMITH: 0.0,
	Constants.JobType.CRAFTSMAN: 0.0,
	Constants.JobType.MINER: 0.0,
	Constants.JobType.FARMER: 0.0,
	Constants.JobType.TAILOR: 0.0,
	Constants.JobType.ALCHEMIST: 0.0,
	Constants.JobType.DOCTOR: 0.0,
	Constants.JobType.BUILDER: 0.0,
	Constants.JobType.SURVIVALIST: 0.0,
	Constants.JobType.LABORER: 0.0,
}

# COMBAT
var base_health: float
var base_move_speed: float = 500.0
var base_damage_multiplier: float	# TODO: Decide whether to use this
var base_attack_speed: float
var base_cool_down_multipler: float

# Magic
var is_magic_enabled: bool = false
var is_fire_magic_enabled: bool = false
var is_ice_magic_enabled: bool = false
var is_storm_magic_enabled: bool = false
var is_support_magic_enabled: bool = false

var magic_levels: Dictionary[Constants.MagicType, float] = {
	Constants.MagicType.FIRE: 0.0,
	Constants.MagicType.ICE: 0.0,
	Constants.MagicType.STORM: 0.0,
	Constants.MagicType.SUPPORT: 0.0,
}

var weapon_levels: Dictionary[Constants.WeaponType, float] = {
	Constants.WeaponType.UNARMED: 0.0,
	Constants.WeaponType.SHORT_SWORD: 0.0,
	Constants.WeaponType.LONG_SWORD: 0.0,
	Constants.WeaponType.SHIELD: 0.0,
	Constants.WeaponType.BOW: 0.0,
	Constants.WeaponType.MACE: 0.0,
	Constants.WeaponType.HAMMER: 0.0,
	Constants.WeaponType.SPEAR: 0.0,
	Constants.WeaponType.BATTLE_AXE: 0.0,
}

var weapon: Weapon = null
var off_hand_weapon: Weapon = null # Only off-hand should be shield

# Character Abilities
var abilities: Array[CharacterAbility] = []

# Level generation chances
var base_job_level_chances: Array = [
	[0, 5.0],   # 5
	[10, 15.0], # 20
	[20, 20.0], # 40
	[30, 40.0], # 70
	[40, 10.0], # 80
	[50, 5.0],  # 85
	[60, 2.5],  # 87.5
	[70, 1.5],  # 99
	[80, 0.5],  # 99.5
	[90, 0.45], # 99.95
	[100, 0.05] # 100
]

var base_weapon_level_chances: Array = [
	[0, 74.70], # 74.70
	[10, 10.0], # 84.70
	[20, 5.0],  # 89.70
	[30, 2.0],  # 91.70
	[40, 1.0],  # 92.70
	[50, .5],   # 93.20
	[60, 3.0],  # 96.20
	[70, 2.5],  # 98.70
	[80, 1.0],  # 99.70
	[90, 0.25], # 99.95
	[100, 0.05] # 100
]

var base_magic_level_chances: Array = [
	[0, 5.0],   # 5
	[10, 15.0], # 20
	[20, 20.0], # 40
	[30, 40.0], # 70
	[40, 10.0], # 80
	[50, 5.0],  # 85
	[60, 2.5],  # 87.5
	[70, 1.5],  # 99
	[80, 0.5],  # 99.5
	[90, 0.45], # 99.95
	[100, 0.05] # 100
]

# A unit will select a type of magic to be enabled in; this is the likely-hood of a specific type to be enabled
# this does NOT define the skill level with that type of magic
var magic_type_chances: Array = [
	[Constants.MagicType.FIRE, 40],
	[Constants.MagicType.ICE, 15],
	[Constants.MagicType.STORM, 5], 
	[Constants.MagicType.SUPPORT, 40]
]

var is_magic_enabled_chance: float = .20
# # This modifies `is_magic_enabled_chance`, making each subsequent attempt to add a magic type (fire,ice,etc.) more difficult
# var is_magic_enabled_modifier: float = 20.0

func generate_new_unit_data() -> void:
	# Generate job levels
	for job_type in job_levels.keys():
		job_levels[job_type] = get_new_job_level()

	# Generate weapon levels
	for weapon_type in weapon_levels.keys():
		weapon_levels[weapon_type] = get_new_weapon_level()
	
	# Magic
	is_magic_enabled = true if (Constants.rng.randf() < is_magic_enabled_chance) else false
	var temp_is_magic_enabled = is_magic_enabled
	while temp_is_magic_enabled:
		var magic_type_result = get_magic_type()
		match magic_type_result:
			Constants.MagicType.FIRE: 
				is_fire_magic_enabled = true
				magic_levels[Constants.MagicType.FIRE] = get_magic_level()
			Constants.MagicType.ICE: 
				is_ice_magic_enabled = true
				magic_levels[Constants.MagicType.ICE] = get_magic_level()
			Constants.MagicType.STORM: 
				is_storm_magic_enabled = true
				magic_levels[Constants.MagicType.STORM] = get_magic_level()
			Constants.MagicType.SUPPORT:
				is_support_magic_enabled = true
				magic_levels[Constants.MagicType.SUPPORT] = get_magic_level()

		temp_is_magic_enabled = true if (Constants.rng.randf() < is_magic_enabled_chance) else false
	
	#print_unit_data()


func get_new_job_level() -> float:
	return clamp(Constants.get_weighted_random(base_job_level_chances) + (Constants.rng.randi_range(-5,5)), 0, 100) 

func get_new_weapon_level() -> float: 
	return clamp(Constants.get_weighted_random(base_weapon_level_chances) + (Constants.rng.randi_range(-5,5)), 0, 100) 

## Return a string which corresponds to a type of magic, defined in `magic_type_chances`
func get_magic_type() -> Constants.MagicType:
	return Constants.get_weighted_random(magic_type_chances)

func get_magic_level() -> float: 
	return clamp(Constants.get_weighted_random(base_magic_level_chances) + (Constants.rng.randi_range(-5,5)), 0, 100) 

## Just for console
func print_unit_data() -> void:
	print("===============================================================================")
	print("\nJOB LEVELS")
	print(job_levels)

	print("\nWEAPON LEVELS")
	print(weapon_levels)

	print("\nMAGIC")
	print(magic_levels)
	print("Is Magic Enabled: ", is_magic_enabled)
	print("Is Fire Magic Enabled: ", is_fire_magic_enabled)
	print("Is Ice Magic Enabled: ", is_ice_magic_enabled)
	print("Is Storm Magic Enabled: ", is_storm_magic_enabled)
	print("Is Support Magic Enabled : ", is_support_magic_enabled)
