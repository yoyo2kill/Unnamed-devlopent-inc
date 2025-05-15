extends Area2D

var enter = false

# Remove the connections in _ready() since they're already set up in the editor
func _ready():
	# No signal connections here - using the ones from the editor
	pass

func _on_body_entered(body):
	print("Body entered: ", body.name)
	enter = true
	
func _on_body_exited(body):
	print("Body exited: ", body.name)
	enter = false
	
func _process(delta):
	if enter:
		if Input.is_action_just_pressed("interact"):
			print("Trying to change scene")
		 
			get_tree().change_scene_to_file("res://scence/node_2d.tscn")
		   
