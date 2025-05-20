extends Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("Boss")



func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	get_tree().change_scene_to_file("res://Hell.tscn")
