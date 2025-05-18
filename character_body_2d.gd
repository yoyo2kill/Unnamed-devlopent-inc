extends CharacterBody2D
class_name enemy1
var time_remaining
var on_fire = false
var fire_damage = 1  # Damage per second
var fire_duration = 1.0  # Total duration in seconds
var fire_timer = 0.0  # Current timer

const speed = 400

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health: TextureProgressBar = $EnemyHealth
@export var fire_damge: float
func _process(delta):
	process_fire(delta)
	process_health_check(delta)

func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()
	
func makepath() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout():
	makepath()

func process_fire(delta):
	if on_fire:
		fire_timer += delta
		if fire_timer >= fire_duration:
			on_fire = false
			fire_timer = 0.0
		else:
			enemy_health.value -= 1.0

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Fireball:
		on_fire = true
		fire_timer = 0.0
		enemy_health.value -= 20

func process_health_check(delta):
	if enemy_health.value <= 0:
		queue_free()
