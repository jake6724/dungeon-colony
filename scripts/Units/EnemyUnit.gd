class_name EnemyUnit
extends Node2D

@onready var area = $UnitArea
@onready var health_bar = $HealthBar

signal enemy_died

var health: float = 100.0
var attackers: Array[PlayerUnit] = [] 

func _ready():
	area.collision_layer = Constants.layer_mapping["enemy_unit"]
	health_bar.value = health

## Add attack to `EnemyUnit`'s `attackers` array. Connect to `new_attackers` `auto_attacking` signal
func add_attacker(new_attacker: PlayerUnit):
	if not new_attacker in attackers: # Don't add attacker if it is already accounted for 
		attackers.append(new_attacker)
		new_attacker.auto_attacking.connect(on_auto_attacked)

func remove_attacker(old_attacker: PlayerUnit):
	# Remove from attackers
	var i = attackers.find(old_attacker)
	# TODO: Make sure attack actually exists first so we don't have to check -1 ? 
	if i != -1: # -1 means that attacker wasn't found in attackers
		attackers.remove_at(i)
		# Disconnect signal
		old_attacker.auto_attacking.disconnect(on_auto_attacked)

func on_auto_attacked(attacker): # Must pass this in somewhere
	print(name, " I was attacked by ", attacker, "!")
	health -= attacker.attack_damage
	print(name, ": My health his now: ", health)
	health_bar.value = health

	if health <= 0:
		enemy_died.emit()
		on_death()

func on_death():
	queue_free()
