extends TextureProgressBar

var mana = value


func _process(delta: float) -> void:
	if mana <= 500:
		mana += 1+delta

func _input(event: InputEvent) -> void:
	if mana >= 100:
		if event.is_action_pressed("spell1"):
			mana -= 100
	else:
		print("no work")
