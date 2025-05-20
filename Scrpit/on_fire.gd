extends Sprite2D


var enemy_instance  

func _ready() -> void:
	visible = false

	enemy_instance = get_node("") 
func _process(delta: float) -> void:
	if enemy_instance and enemy_instance.on_fire:
		visible = true
	else:
		visible = false
