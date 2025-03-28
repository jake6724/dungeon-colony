class_name EnemyUnit
extends Unit

@onready var area = $UnitArea
@onready var health_bar = $HealthBar

var health: float = 100.0
var attackers: Array[PlayerUnit] = [] 
var is_alive: bool = true

func _ready():
	area.collision_layer = Constants.layer_mapping["enemy_unit"]
	health_bar.value = health

# TODO: Make more calculations on damage based on type
## Returns `true` if `Unit` died, `false` if not
func take_damage(weapon_damage: float, _weapon_damage_type: Constants.WeaponDamageType, 
magic_damage: float, _magic_damage_type: Constants.MagicDamageType) -> bool:

	health -= weapon_damage
	health -= magic_damage
	health_bar.value = health

	if health <= 0:
		return true
	else:
		return false
