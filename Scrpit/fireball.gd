extends Area2D
class_name Fireball

var ENEMY = preload("res://scence/enemy.tscn")
var speed = 700
var fireball_dir

func _process(delta):
	# Direction is already normalized, so just multiply by speed and delta
	position += fireball_dir * speed * delta

func _on_area_entered(area: PhysicsBody2D) -> void:
	# Use is_in_group() or check class_name instead
	if area.is_in_group("enemy_hitbox") or area.get_parent().is_in_group("enemy"):
		print("yay")
		queue_free()
