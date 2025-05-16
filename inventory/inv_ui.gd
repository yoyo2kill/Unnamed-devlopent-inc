extends Control

@onready var inv:Inv = preload("res://inventory/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false


func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()

func update_slots():
	for i in range(min(inv.slot.size(), slots.size())):
		slots[i].update(inv.slot[i])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("i"):
		if is_open:
			close()
		else:
			open()



func close():
	visible = false
	is_open = false
	
func open():
	visible = true
	is_open = true
