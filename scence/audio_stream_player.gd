extends AudioStreamPlayer

@onready var tooltip_1: CanvasLayer = $"../CharacterBody2D/Following UI/Tooltip1"
var played = false
func _process(delta: float) -> void:
	if tooltip_1.visible == false and played == false:
		play()
		played = true
