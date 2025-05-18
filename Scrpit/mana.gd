extends TextureProgressBar



func _process(delta: float) -> void:
	if value <= 1000:
		value += 1+delta
