extends Area2D
class_name Fireball

var speed = 700
var fireball_dir

func _process(delta):
	# Direction is already normalized, so just multiply by speed and delta
	position += fireball_dir * speed * delta

func _on_area_entered(area) -> void:
	var enemy_nodes = get_tree().get_nodes_in_group("enemy_hitbox")
	for enemy in enemy_nodes:
		print("yay")
		queue_free()
