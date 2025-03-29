extends Node

var attack_queue: Array = []
var processing_in_progress: bool = false

func _physics_process(_delta):
	if attack_queue: 
		#TODO: Make sure that only one gets processed at a time
		process_next_attack(attack_queue.pop_front())

## Process the next attack in `attack_queue`
func process_next_attack(attack: Attack) -> void:
	if attack.attacker and attack.attacker.is_alive:
		if attack.receiver and attack.receiver.is_alive:
			var receiver_died = attack.receiver.take_damage(attack)
			if receiver_died: # Reset data for attacker, free receiver
				attack.attacker.target = null
				attack.receiver.queue_free()

		else: # If the receiver didn't exist or was dead, reset attacker's target
			attack.attacker.target = null

## Add a new attack object to `attack_queue`
func add_attack(new_attack: Attack) -> void:
	attack_queue.append(new_attack)
