extends Area2D
class_name Freeze

var ENEMY = preload("res://scence/enemy.tscn")
var speed = 700
var Freeze_dir = Vector2.RIGHT  # Default direction if not set

func _ready():
	# Connect the area_entered signal if not connected in the editor
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _process(delta):
	# Move the fireball
	position +=  Freeze_dir * speed * delta

# This is called when the fireball enters another area
func _on_area_entered(area):
	print("Area entered: ", area.name)
	
	# Check if the area is in the hitbox group
	if area.is_in_group("enemy_hitbox"):
		print("Hit enemy hitbox!")
		queue_free()
