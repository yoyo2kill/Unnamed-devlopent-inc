extends Area2D
class_name Fireball

var ENEMY = preload("res://scence/enemy.tscn")
var enemy = ENEMY.instantiate()
var speed = 700

var fireball_dir

func _process(delta):
	position -= fireball_dir * speed * delta
	

	


func _on_area_entered(area: Area2D) -> void:
	if area is enemy_hitbox:
		print ("yay")
		queue_free()
