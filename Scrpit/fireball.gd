extends Area2D
class_name Fireball

var ENEMY = preload("res://scence/enemy.tscn")
var speed = 700
var fireball_dir

func _process(delta):
	# Direction is already normalized, so just multiply by speed and delta
	position += fireball_dir * speed * delta

func _on_area_entered(area) -> void:
	if area is enemy_hitbox:
		print("yay")
		queue_free()
