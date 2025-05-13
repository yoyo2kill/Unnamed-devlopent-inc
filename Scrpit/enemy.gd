extends CharacterBody2D

const speed = 200

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health: TextureProgressBar = $EnemyHealth



func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()
	
func makepath() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout():
	makepath()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Fireball:
		enemy_health.value -= 20
		if enemy_health.value <= 0:
			queue_free()
