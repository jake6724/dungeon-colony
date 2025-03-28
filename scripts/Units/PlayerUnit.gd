class_name PlayerUnit
extends Unit

# TODO: Make path lines center

# Node References
@onready var main = get_tree().root.get_node("Main")
@onready var ow: Overworld = main.get_node("Overworld")
@onready var pf: PathFinder = ow.get_node("PathFinding")

# Child Node References
@onready var sprite = get_node("UnitSprite")
@onready var selected_sprite = $SelectedSprite
@onready var area = get_node("UnitArea")
@onready var collision = area.get_node("UnitCollision")

# General Unit Data
var data: UnitData = UnitData.new()
var grid_position: Vector2 = Vector2()
var is_selected: bool = false
var preserve: bool = false
var is_moving: bool = false

# Pathfinding
var path: PackedVector2Array = []
var path_line: Line2D # TODO Make this line a resource ?
var path_target_panel: Panel

# Combat
var health: float = 100
var is_alive: bool = true
var weapon_damage: float
var magic_damage: float
var attack_speed: float
var move_speed: float
var can_attack: bool = false
var max_range: Vector2 = Vector2(1000, 1000)
@export var weapon: WeaponData = Constants.player_unit_unarmed
@export var weapon_off_hand: WeaponData
@export var armor_head: ArmorData
@export var armor_chest: ArmorData
@export var armor_legs: ArmorData

var target_line: Line2D
var auto_attack_timer: Timer
var auto_attack_line: Line2D
var auto_attack_line_timer: Timer
var target: EnemyUnit = null:
	set(value):
		if value != target: # Don't run if new target is the same as current
			if value: # Target was NOT set to EnemyUnit object
				target = value
				auto_attack_timer.start(attack_speed) # ? 

			else: # Target was set to null
				target = value
				auto_attack_timer.stop()
				can_attack = false

# Abilities
var abilities_array: Array[AbilityData] = []
@export var ability_1 = AbilityData
@export var ability_2 = AbilityData
@export var ability_3 = AbilityData
@export var ability_4 = AbilityData

# # ABILITY TESTING - NOT PERMANENT SET UP
# @export var test_ability_1: AbilityData
# @export var test_ability_2: AbilityData
# @export var test_ability_3: AbilityData
# @export var test_ability_4: AbilityData
# var ability_fireball = load("res://data/ability/character/fireball.tres")
# var ability_iceball = load("res://data/ability/character/ice_ball.tres") 
# var ability_stormball = load("res://data/ability/character/storm_ball.tres")
# var ability_heal = load("res://data/ability/character/heal.tres")

func _ready():
	# Configure basic data
	grid_position = Constants.world_to_grid(position)
	area.collision_layer = Constants.layer_mapping["unit"]
	sprite.z_index = Constants.z_index_mapping["player_unit_sprite"]
	selected_sprite.z_index = Constants.z_index_mapping["player_unit_select_sprite"]
	
	# Create unit data
	data.generate_new_unit_data()

	# Configure path line visualization
	path_line = Line2D.new()
	path_line.default_color = (Color(1.0, 1.0, 1.0, 0.500))
	path_line.width = 10
	path_line.z_index = Constants.z_index_mapping["GUI"]
	main.call_deferred("add_child", path_line) # Main is too busy setting up its own children to add immediately

	# Configure path target visualization
	path_target_panel = Panel.new()
	path_target_panel.size = Vector2(Constants.cell_size, Constants.cell_size)
	var style_box = load("res://scripts/Units/path_target_panel_style.tres")
	path_target_panel.add_theme_stylebox_override("panel", style_box)
	main.call_deferred("add_child", path_target_panel)

	# Configure auto attack data
	auto_attack_timer = Timer.new()
	auto_attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS # Make timer run on physics_process
	auto_attack_timer.timeout.connect(on_auto_attack_timer_timeout)
	add_child(auto_attack_timer)

	# Configure auto attack visualization
	auto_attack_line = Line2D.new()
	auto_attack_line.default_color = Color.RED
	auto_attack_line.width = 10
	main.call_deferred("add_child", auto_attack_line) # Child of main to avoid transform issues
	auto_attack_line_timer = Timer.new()
	auto_attack_line_timer.one_shot = true
	auto_attack_line_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	auto_attack_line_timer.timeout.connect(on_auto_attack_line_timer_timeout)
	add_child(auto_attack_line_timer)

	# Initialize Combat data
	set_weapon_damage()
	set_attack_speed()
	set_move_speed()

func _process(delta):
	move(delta)
	auto_attack()

func move(delta):
	if path.size() > 0:
		is_moving = true # Used to access moving info outside of this class
		# Destination has been reached
		if position.distance_to(path[0]) < 10:
			grid_position = Constants.world_to_grid(path[0])
			position = path[0]
			path.remove_at(0)
			path_line.points = path

		# Still moving to destination
		else:
			# Don't allow grid_position to ever be an invalid spot
			if not ow.grid[Constants.world_to_grid(path[0])].is_navigable:
				grid_position = pf.find_valid_point(grid_position)
			else:
				grid_position = Constants.world_to_grid(path[0])
			position += (path[0] - position).normalized() * move_speed * delta  
	# All points on path have been traversed
	else: 
		path_target_panel.visible = false
		is_moving = false

func set_path_to(destination_gp) -> void:
	# Reset path target reservation; we can't assume that our grid position is the target and grid_position was even reserved.
	# Instead of this we could just reserve/unreserve as unit moves along the path

	if path:
		ow.grid[Constants.world_to_grid(path[-1])].is_reserved = false
		path = []
		path_line.points = path
	else:
		ow.grid[grid_position].is_reserved = false

	ow.grid[grid_position].is_reserved = false
	target = null # Stop attacking every time unit moves
	path = pf.get_astar_path(grid_position, destination_gp)
	if path:
		ow.grid[Constants.world_to_grid(path[-1])].is_reserved = true
		path_line.points = path
		path_target_panel.position = path[-1]
		path_target_panel.visible = true
	else:
		ow.grid[grid_position].is_reserved = true
		
## Reset path and unreserve path target. Find the closest grid point to current position and snap to grid. Reserve 
## new grid position
func stop_moving() -> void:
	if path:
		ow.grid[Constants.world_to_grid(path[-1])].is_reserved = false
		path = []
		path_line.points = path
	
	grid_position = Constants.world_to_grid(position)
	position = Constants.grid_to_world(grid_position)
	ow.grid[grid_position].is_reserved = true
	 
func auto_attack():
	if can_attack and target:
		# TODO: Set up data for magic damage
		var attack = Attack.new(self, target, weapon_damage, weapon.damage_type, magic_damage, Constants.MagicDamageType.NONE)
		CombatManager.add_attack(attack)

		# Reset auto attack data and timer
		auto_attack_timer.start(attack_speed)
		can_attack = false
		
		if target: # Ensure target wasn't killed by auto_attack
			auto_attack_line.points = PackedVector2Array([position, target.position])
			auto_attack_line.visible = true
			auto_attack_line_timer.start(.1)

func on_auto_attack_timer_timeout(): 
	can_attack = true

func on_target_died():
	target = null

func on_auto_attack_line_timer_timeout():
	auto_attack_line.visible = false

## Calculate the attack damage for the PlayerUnit. This only sets the internal variable, no return
func set_weapon_damage() -> void:
	var armor_damage_buff = 0.0
	if armor_head:
		armor_damage_buff += armor_head.damage_buff
	if armor_chest:
		armor_damage_buff += armor_chest.damage_buff
	if armor_legs:
		armor_damage_buff += armor_legs.damage_buff

	weapon_damage = (weapon.damage + armor_damage_buff + (data.weapon_levels[weapon.type] * Constants.weapon_level_modifier))

## Calculate the attack speed for the PlayerUnit. This only sets the internal variable, no return
func set_attack_speed() -> void:
	var armor_attack_speed_modifier = 1.0
	if armor_head:
		armor_attack_speed_modifier += armor_head.attack_speed_modifer
	if armor_chest:
		armor_attack_speed_modifier += armor_chest.attack_speed_modifer
	if armor_legs:
		armor_attack_speed_modifier += armor_legs.attack_speed_modifer

	attack_speed = (weapon.attack_speed / (1 + (data.weapon_levels[weapon.type] / 100)) * armor_attack_speed_modifier) # Could add buff modifier here ( ex; * 1.2)

func set_move_speed() -> void:
	var armor_move_speed_modifier: float = 1.0
	if armor_head:
		armor_move_speed_modifier += armor_head.move_speed_modifier
	if armor_chest:
		armor_move_speed_modifier += armor_chest.move_speed_modifier
	if armor_legs:
		armor_move_speed_modifier += armor_legs.move_speed_modifier

	var weapon_move_speed_modifier: float = 1.0 + weapon.move_speed_modifier
	if weapon_off_hand: weapon_move_speed_modifier += weapon_off_hand.move_speed_modifier
	
	# This does not yet account for Buffs/Debuffs
	move_speed = data.base_move_speed * armor_move_speed_modifier * weapon_move_speed_modifier

func take_damage(weapon_damage, magic_damage):
	health -= weapon_damage
	health -= magic_damage
