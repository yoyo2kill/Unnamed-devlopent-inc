extends Control

var current_heart

func _ready():
	current_heart = 6
	update_heart_num()
	pass
	
func update_heart_num():
	$"../CharacterBody2D/heart".update_heart(current_heart)

func _on_button_pressed() -> void:
	
	current_heart +=1
	update_heart_num()
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	
	current_heart -=1
	update_heart_num()
	pass # Replace with function body.
