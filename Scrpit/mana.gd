extends TextureProgressBar



func _process(delta: float) -> void:
	if value <= 500:
		value += 1+delta

func _input(event: InputEvent) -> void:
	if value >= 100:
		if event.is_action_pressed("spell1"):
			value -= 100
	else:
		print("no work")
