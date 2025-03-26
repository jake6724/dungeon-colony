class_name UnitData
extends Object # Not a resource cause we just want to make new ones at runtime randomly. Not like an ability where they are pre-defined 

# General
var name: String = ""
var is_player_unit = true

# Jobs
var carpenter_level: float = 0.0
var stoneworker_level: float = 0.0 # Maybe unecessary
var blacksmith_level: float = 0.0 # Metal weapons and armor
var craftsman_level: float = 0.0 # Wooden weapons and armor, bow, other
var miner_level: float = 0.0
var farmer_level: float = 0.0 # Plants and animals
var tailor_level: float = 0.0 # Leather and cloth
var alchemist_level: float = 0.0 # Potions
var doctor_level: float = 0.0 # Physical doctoring idk
var builder_level: float = 0.0 # Construction
var survivalist_level: float = 0.0 # Hunting, fishing, gathering, maybe something else for late game in dungeon 
var laborer_level: float = 0.0 # Hauling speed, lumberjack, and other random non-specialist task

# COMBAT
var base_health: float
var base_move_speed: float = 500
var base_damage_multiplier: float
var base_attack_speed: float
var base_cool_down_multipler: float

# Magic
var is_magic_enabled: bool = false
var is_fire_magic_enabled: bool = false
var is_ice_magic_enabled: bool = false
var is_storm_magic_enabled: bool = false
var is_support_magic_enabled: bool = false

var fire_magic_level: float = 0.0
var ice_magic_level: float = 0.0
var storm_magic_level: float = 0.0
var support_magic_level: float = 0.0 # This has 3 weapons that all work off of this skill

# Weapon
var unarmed_level: float = 0.0
var long_sword_level: float = 0.0
var short_sword_level: float = 0.0
var shield_level: float = 0.0
var bow_level: float = 0.0
var mace_level: float = 0.0
var hammer_level: float = 0.0
var spear_level: float = 0.0
var battle_axe_level: float = 0.0

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
	["fire", 40],
	["ice", 15],
	["storm", 5], 
	["support", 40]
]

var is_magic_enabled_chance: float = .20
# # This modifies `is_magic_enabled_chance`, making each subsequent attempt to add a magic type (fire,ice,etc.) more difficult
# var is_magic_enabled_modifier: float = 20.0

func generate_new_unit_data() -> void:
	# Generate Job Levels
	carpenter_level = get_new_job_level()
	stoneworker_level = get_new_job_level()
	blacksmith_level = get_new_job_level()
	craftsman_level = get_new_job_level()
	miner_level = get_new_job_level()
	farmer_level = get_new_job_level()
	tailor_level = get_new_job_level()
	alchemist_level = get_new_job_level()
	doctor_level = get_new_job_level()
	builder_level = get_new_job_level()
	survivalist_level = get_new_job_level()
	laborer_level = get_new_job_level()

	# Generate Combat Levels
	unarmed_level = get_new_weapon_level()
	long_sword_level = get_new_weapon_level()
	short_sword_level = get_new_weapon_level()
	shield_level = get_new_weapon_level()
	bow_level = get_new_weapon_level()
	mace_level = get_new_weapon_level()
	hammer_level = get_new_weapon_level()
	spear_level = get_new_weapon_level()
	battle_axe_level = get_new_weapon_level()

	# Magic
	is_magic_enabled = true if (Constants.rng.randf() < is_magic_enabled_chance) else false
	var temp_is_magic_enabled = is_magic_enabled
	while temp_is_magic_enabled:
		var magic_type_result = get_magic_type()
		match magic_type_result:
			"fire": 
				is_fire_magic_enabled = true
				fire_magic_level = get_magic_level()
			"ice": 
				is_ice_magic_enabled = true
				ice_magic_level = get_magic_level()
			"storm": 
				is_storm_magic_enabled = true
				storm_magic_level = get_magic_level()
			"support":
				is_support_magic_enabled = true
				support_magic_level = get_magic_level()

		temp_is_magic_enabled = true if (Constants.rng.randf() < is_magic_enabled_chance) else false


func get_new_job_level() -> float:
	return clamp(Constants.get_weighted_random(base_job_level_chances) + (Constants.rng.randi_range(-5,5)), 0, 100) 

func get_new_weapon_level() -> float: 
	return clamp(Constants.get_weighted_random(base_weapon_level_chances) + (Constants.rng.randi_range(-5,5)), 0, 100) 

## Return a string which corresponds to a type of magic, defined in `magic_type_chances`
func get_magic_type() -> String:
	return Constants.get_weighted_random(magic_type_chances)

func get_magic_level() -> float: 
	return clamp(Constants.get_weighted_random(base_magic_level_chances) + (Constants.rng.randi_range(-5,5)), 0, 100) 

## Just for console
func print_unit_data() -> void:
	print("\nJOB LEVELS")
	print("Carpenter: ", carpenter_level)
	print("Stonworker: ", stoneworker_level)
	print("Blacksmith: ", blacksmith_level)
	print("Craftsman: ", craftsman_level)
	print("Miner: ", miner_level)
	print("Farmer: ", farmer_level)
	print("Tailor: ", tailor_level)
	print("Alchemist: ", alchemist_level)
	print("Doctor: ", doctor_level)
	print("Builder: ", builder_level)
	print("Survivalist: ", survivalist_level)
	print("Laborer: ", laborer_level)

	print("\nWEAPON LEVELS")
	print("Unarmed: ",unarmed_level)
	print("Long Sword: ",long_sword_level)
	print("Short Sword: ",short_sword_level)
	print("Shield: ",shield_level )
	print("Bow: ",bow_level)
	print("Mace: ",mace_level)
	print("Hammer: ",hammer_level)
	print("Spear: ",spear_level )
	print("Battle Axe: ",battle_axe_level)

	print("\nMAGIC")
	print("Is Magic Enabled: ", is_magic_enabled)
	print("Is Fire Magic Enabled: ", is_fire_magic_enabled)
	print("Is Ice Magic Enabled: ", is_ice_magic_enabled)
	print("Is Storm Magic Enabled: ", is_storm_magic_enabled)
	print("Is Support Magic Enabled : ", is_support_magic_enabled)
	print("Fire Magic Level: ", fire_magic_level)
	print("Ice Magic Level: ", ice_magic_level)
	print("Storm Magic Level: ", storm_magic_level)
	print("Support Magic Level: ", support_magic_level)

func reset_all_data() -> void: 
	carpenter_level = 0
	stoneworker_level = 0
	blacksmith_level = 0
	craftsman_level = 0
	miner_level = 0
	farmer_level = 0 
	tailor_level = 0
	alchemist_level = 0
	doctor_level = 0
	builder_level = 0
	survivalist_level = 0
	laborer_level = 0 

	is_magic_enabled = false
	is_fire_magic_enabled = false
	is_ice_magic_enabled = false
	is_storm_magic_enabled = false
	is_support_magic_enabled = false
	fire_magic_level = 0
	ice_magic_level = 0
	storm_magic_level = 0
	support_magic_level = 0
	unarmed_level = 0
	long_sword_level = 0
	short_sword_level = 0
	shield_level = 0
	bow_level = 0
	mace_level = 0
	hammer_level = 0
	spear_level = 0
	battle_axe_level = 0