extends Sprite2D

@export var item: InvItem
var PLAYER = preload("res://scence/player.tscn")
var player = PLAYER.instantiate()

func _process(delta: float) -> void:
	player.collect(item)


func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
