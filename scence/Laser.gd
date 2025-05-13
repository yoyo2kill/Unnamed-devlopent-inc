extends Node2D


@export var beam_length : float = 100

@onready var beam: Line2D = $beam

var _is_active : bool

func _ready() -> void:
	visible = false
	_is_active = false
	_set_length(beam_length)
	
func _set_length(length: float):
	beam.points[1].x = length

func activate():
	if !_is_active:
		_is_active = true
		visible = true

func deactivate():
	if _is_active:
		_is_active = false
		visible = false
