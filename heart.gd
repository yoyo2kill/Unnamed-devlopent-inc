
extends HBoxContainer

var heart_full = preload("res://Assets/brackeys_platformer_assets/2381669-6ade057fd7f23ced.webp")
var heart_half = preload("res://Assets/brackeys_platformer_assets/2381669-df0942608cf9d9c4.webp")
var heart_empty = preload("res://Assets/brackeys_platformer_assets/2381669-fac9de5069d05001.webp")
enum TYPES {type1}

func update_heart(value):
	update_type1(value)
	
func update_type1(value):
	for i in self.get_child_count():
		if i*2 < value - 1:
			get_child(i).texture = heart_full
		elif i*2 == value - 1:
			get_child(i).texture = heart_half
		else:
			get_child(i).texture = heart_empty
