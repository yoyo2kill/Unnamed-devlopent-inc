extends Area2D
class_name Electricshock

var speed = 1000
var fireball_dir

func _process(delta):
	# Direction is already normalized, so just multiply by speed and delta
	position += fireball_dir * speed * delta

func _on_area_entered(area) -> void:
	var enemy_nodes = get_tree().get_nodes_in_group("enemy_hitbox")
	for enemy in enemy_nodes:
		print("zap")
		queue_free()
