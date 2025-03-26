class_name AbilityData
extends Resource # Resource because we want to pre-define these and allow Nodes to use them

enum CastType {PROJECTILE_AOE, PROJECTILE_SKILLSHOT, PROJECTILE_SELECT, SELFCAST, SELFCAST_AOE, MELEE_SELECT, CONE_SELECT}

@export var name: String = ""
@export var display_name: String = ""
@export var desc: String = ""
@export var cooldown: float = 0 # How long ability needs to recharge
@export var weapon_damage_type: Constants.WeaponDamageType
@export var magic_damage_type: Constants.MagicDamageType

@export var is_weapon_ability = false
@export var is_character_ability = false
@export var is_magic: bool
@export var cast_type: CastType 

@export var cast_time: float = 0.0
@export var animation_names: Array[String] = [] # Maybe needs to be a dict whith when the animation should be used 

@export var damage: float = 0.0
@export var damage_duration: float = 0.0
@export var damage_interval: float = 0.0
# @export var damage_type: int = 0 # Enum

@export var buff: Buff = null # Must be assigned a `Buff` Resource to use
@export var buff_duration: float = 0.0
@export var buff_interval: float = 0.0

@export var healing: float = 0.0
@export var healing_duration: float = 0.0
@export var healing_interval: float = 0.0

@export var stun_duration: float = 0.0

@export var slow_strength: float = 0.0
@export var slow_duration: float = 0.0

@export var root_duration: float = 0.0

# Knockback stength is the total distance a character should move away from the source of knockback (Assuming no obstacles blocked path)
# So a value of 500 would set them to update their position 500 away. This will be applied by a constant amount over multiple frames 
# until the final position has been reached
@export var knockback_strength: float = 0.0 