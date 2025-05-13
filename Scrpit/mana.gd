extends TextureProgressBar



func _process(delta: float) -> void:
	if value <= 500:
		value += 1+delta
