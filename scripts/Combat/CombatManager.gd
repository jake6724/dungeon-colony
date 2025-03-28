extends Node

var attack_queue: Array = []
var processing_in_progress: bool = false

func _physics_process(_delta):
	if attack_queue: 
		process_next_attack(attack_queue.pop_front())

## Process the next attack in `attack_queue`
func process_next_attack(attack: Attack) -> void:
	# Check if # Check if attacker and receiver both still exist
	if attack.attacker and attack.receiver:
		# Check if attacker and receiver are both alive
		if attack.attacker.is_alive and attack.receiver.is_alive:
			# If both are alive, apply the damage to receiver
			var receiver_died = attack.receiver.take_damage(attack.weapon_damage, attack.weapon_damage_type, 
			attack.magic_damage, attack.magic_damage_type)

			if receiver_died: # Reset data for attacker, free receiver
				attack.attacker.target = null
				attack.receiver.queue_free()
			
	else: # If the enemy wasn't able to recieve attack (cause dead), should auto attack timer reset ? 
		pass 

## Add a new attack object to `attack_queue`
func add_attack(new_attack: Attack) -> void:
	attack_queue.append(new_attack)
