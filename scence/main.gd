extends Node2D

@onready var tooltip_1: CanvasLayer = $"CharacterBody2D/Following UI/Tooltip1"
@onready var tooltip_2: CanvasLayer = $"CharacterBody2D/Following UI/Tooltip2"
@onready var panel_2: Panel = $CharacterBody2D/Camera2D/Panel2
@onready var tooltip_3: CanvasLayer = $"CharacterBody2D/Following UI/Tooltip3"
@onready var tooltip_4: CanvasLayer = $"CharacterBody2D/Following UI/Tooltip4"

# Flag variables to track whether each tooltip has been shown
var tooltip_1_shown = false
var tooltip_2_shown = false
var tooltip_3_shown = false
var tooltip_4_shown = false
var tooltip_5_shown = false
func _ready() -> void:
	# Make all tooltips initially invisible
	tooltip_1.visible = false
	tooltip_2.visible = false
	tooltip_3.visible = false
	tooltip_4.visible = false
	
	# Show the first tooltip only once
	if not tooltip_1_shown:
		tooltip_1.visible = true
		Engine.time_scale = 0.0
		tooltip_1_shown = true

func _process(delta: float) -> void:
	# Tooltip 2 - Only show once when wave_number == 2
	if $CharacterBody2D/Camera2D/Panel2.wave_number == 2 and not tooltip_2_shown:
		tooltip_2.visible = true
		Engine.time_scale = 0.0
		tooltip_2_shown = true
	
	# Tooltip 3 - Only show once when wave_number == 3
	if $CharacterBody2D/Camera2D/Panel2.wave_number == 3 and not tooltip_3_shown:
		tooltip_3.visible = true
		Engine.time_scale = 0.0
		tooltip_3_shown = true
	
	# Tooltip 4 - Only show once when wave_number == 4
	if $CharacterBody2D/Camera2D/Panel2.wave_number == 4 and not tooltip_4_shown:
		tooltip_4.visible = true
		Engine.time_scale = 0.0
		tooltip_4_shown = true
	if $CharacterBody2D/Camera2D/Panel2.wave_number == 5 and not tooltip_5_shown:
		get_tree().change_scene_to_file("res://Hell.tscn")
		tooltip_5_shown = true
