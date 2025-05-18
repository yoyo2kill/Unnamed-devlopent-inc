extends Area2D
class_name Lightning

var ENEMY = preload("res://scence/enemy.tscn")
var speed = 700
var lightning_dir

func _process(delta):
	# Direction is already normalized, so just multiply by speed and delta
	position += lightning_dir * speed * delta

func _on_area_entered(area) -> void:
	if area is enemy_hitbox:
		print("zap")
		queue_free()
