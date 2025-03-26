class_name PlayerUnit
extends Node2D

# Node References
@onready var main = get_tree().root.get_node("Main")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var pf: PathFinder = ow.get_node("PathFinding")

# Child Node References
@onready var sprite = get_node("UnitSprite")
@onready var selected_sprite = $SelectedSprite
@onready var area = get_node("UnitArea")
@onready var collision = area.get_node("UnitCollision")

var grid_position: Vector2 = Vector2()
var center: Vector2

# TODO tidy up all these
var data: UnitData = UnitData.new()
var is_selected: bool = false
var preserve: bool = false
var target_line: Line2D
var max_range: Vector2 = Vector2(1000, 1000)

var path: PackedVector2Array = []
var path_line: Line2D # TODO Make this line a resource 
var path_target_panel: Panel
var is_moving: bool = false

var target: EnemyUnit

var auto_attack_timer: Timer


# ABILITY TESTING - NOT PERMANENT SET UP
var abilities_array: Array[AbilityData] = []
@export var test_ability_1: AbilityData
@export var test_ability_2: AbilityData
@export var test_ability_3: AbilityData
@export var test_ability_4: AbilityData
var ability_fireball = load("res://data/ability/character/fireball.tres")
var ability_iceball = load("res://data/ability/character/ice_ball.tres") 
var ability_stormball = load("res://data/ability/character/storm_ball.tres")
var ability_heal = load("res://data/ability/character/heal.tres")

# WEAPON TESTING - NOT PERMANENT SET UP
var weapon: WeaponData = null # TODO: Needs a default of unarmed
var active_weapon_level: float
var test_long_sword: WeaponData = load("res://data/weapon/test_long_sword.tres")

# ARMOR TESTING 
var armor_head: ArmorData = null # TODO: These need a default of naked
var armor_chest: ArmorData = null
var armor_legs: ArmorData = null
# TODO: All weapon, armor, ability resources should go under constants or a similar file
var test_chestplate: ArmorData = load("res://data/armor/test_chestplate.tres")
var test_no_helmet: ArmorData = load("res://data/armor/test_no_helmet.tres")
var test_no_greaves: ArmorData = load("res://data/armor/test_no_greaves.tres")

var attack_damage: float
var attack_speed: float

var can_attack: bool = true

func _ready():
	grid_position = ow.worldToGrid(position)
	# center = grid_position + Vector2(32,32)
	area.collision_layer = Constants.layer_mapping["unit"]
	sprite.z_index = Constants.z_index_mapping["player_unit_sprite"]
	selected_sprite.z_index = Constants.z_index_mapping["player_unit_select_sprite"]
	data.generate_new_unit_data()
	# data.print_unit_data()

	# Path Visualization 
	# TODO: Make lines center!
	path_line = Line2D.new()
	path_line.default_color = (Color(1.0, 1.0, 1.0, 0.500))
	path_line.width = 10
	path_line.z_index = Constants.z_index_mapping["GUI"]
	main.call_deferred("add_child", path_line) # Main is too busy setting up its own children to add immediately

	# Create Path Target Panel, set theme
	path_target_panel = Panel.new()
	path_target_panel.size = Vector2(Constants.cell_size, Constants.cell_size)
	var style_box = load("res://scripts/Units/path_target_panel_style.tres")
	path_target_panel.add_theme_stylebox_override("panel", style_box)
	main.call_deferred("add_child", path_target_panel)

	# # ABILITY TESTING - NOT PERMANENT SET UP
	if test_ability_1:
		abilities_array.append(test_ability_1)
	if test_ability_2:
		abilities_array.append(test_ability_2)
	if test_ability_3:
		abilities_array.append(test_ability_3)
	if test_ability_4:
		abilities_array.append(test_ability_4)

	# WEAPON TESTING - NOT PERMANENT SET UP
	if test_long_sword:
		weapon = test_long_sword
	active_weapon_level = get_active_weapon_level()

	# ARMOR TESTING
	if test_no_helmet:
		armor_head = test_no_helmet
	if test_chestplate:
		armor_chest = test_chestplate
	if test_no_greaves:
		armor_legs = test_no_greaves
	set_attack_damage()
	set_attack_speed()

	auto_attack_timer = Timer.new()
	auto_attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS # Make timer run on physics_process
	auto_attack_timer.timeout.connect(on_auto_attack_timer_timeout)
	add_child(auto_attack_timer) # Add as a child of PlayerUnit

func _process(delta):
	move(delta)
	auto_attack()

func move(delta):
	# Check if there are more points in the path to traverse
	if path.size() > 0:
		is_moving = true
		if position.distance_to(path[0]) < 10:
			grid_position = Constants.world_to_grid(path[0])
			position = path[0]
			path.remove_at(0)
			path_line.points = path

			if path.size() == 0:
				path_target_panel.visible = false

		else:
			grid_position = Constants.world_to_grid(position)
			position += (path[0] - position).normalized() * data.base_move_speed * delta  
	else:
		is_moving = false


func set_path_to(target_grid_point) -> void:
	if ow.grid.has(target_grid_point):
		# Unreserve current grid
		ow.grid[grid_position].is_reserved = false
		# Reset path
		path = []

		if not ow.grid[target_grid_point].is_reserved:
			ow.grid[target_grid_point].is_reserved = true
			path = pf.getPath(grid_position, target_grid_point)
		else:
			# while path.size() < 0:
				for direction in Constants.ORTHOGONAL_DIRECTIONS:
					if ow.grid.has(target_grid_point + direction):
						if not ow.grid[(target_grid_point + direction)].is_reserved and ow.grid[(target_grid_point + direction)].is_navigable:
							target_grid_point = target_grid_point + direction
							ow.grid[target_grid_point].is_reserved = true
							path = pf.getPath(grid_position, target_grid_point)

		if path:
			path_line.points = path
			path_target_panel.position = path[-1]
			path_target_panel.visible = true
	else:
		print("Invalid grid point")

func find_valid_target_point_helper():
	# var target_found = false

	for direction in Constants.ORTHOGONAL_DIRECTIONS:
		pass

	pass

func auto_attack():
	if can_attack:
		# Put the attack function, or call to enemy or whatever here
		print(name, " attacked!")
		
		# Start attack timer based on attack speed
		auto_attack_timer.start(attack_speed)
		can_attack = false
	else:
		pass

func on_auto_attack_timer_timeout(): 
	can_attack = true

## Calculate the attack damage for the PlayerUnit. This only sets the internal variable, no return
func set_attack_damage() -> void:
	# TODO: All units should have a default armor and weapon; naked and unarmed
	# d = Weapon damage + Σ of Armor Damage + (weapon level * const weapon_level_modifier)
	attack_damage = (weapon.damage + (armor_head.damage_buff + armor_chest.damage_buff + armor_legs.damage_buff) + 
	(active_weapon_level * Constants.weapon_level_modifier))

## Calculate the attack speed for the PlayerUnit. This only sets the internal variable, no return
func set_attack_speed() -> void:
	var total_armor_modifier = 1 + (armor_head.attack_speed_modifer + armor_chest.attack_speed_modifer + armor_legs.attack_speed_modifer)
	attack_speed = weapon.attack_speed / (1 + (active_weapon_level / 100)) * total_armor_modifier

	# print("Weapon level calculation: ", (1 + (active_weapon_level / 100)))
	# print("Base weapon Attack Speed: ", weapon.attack_speed)
	# print("Attack speed: ", attack_speed)

func get_active_weapon_level():
	match weapon.type:
		Constants.WeaponType.SHORT_SWORD:
			return data.short_sword_level
		Constants.WeaponType.LONG_SWORD:
			return data.long_sword_level
		Constants.WeaponType.SHIELD:
			return data.shield_level
		Constants.WeaponType.BOW:
			return data.bow_level
		Constants.WeaponType.MACE:
			return data.mace_level
		Constants.WeaponType.HAMMER:
			return data.hammer_level
		Constants.WeaponType.SPEAR:
			return data.spear_level
		Constants.WeaponType.BATTLE_AXE:
			return data.battle_axe_level
		Constants.WeaponType.FLAME_STAFF:
			return data.fire_magic_level
		Constants.WeaponType.ICE_STAFF:
			return data.ice_magic_level
		Constants.WeaponType.STORM_STAFF:
			return data.storm_magic_level
		Constants.WeaponType.SUPPORT_STAFF:
			return data.support_magic_level
