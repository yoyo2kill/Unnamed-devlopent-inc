extends CharacterBody2D
class_name enemy
var time_remaining
var on_fire = false
var fire_damage = 1  # Damage per second
var fire_duration = 1.0  # Total duration in seconds
var fire_timer = 0.0  # Current timer

const SPEED = 200
@export var detection_radius = 500.0
@export var shooting_distance = 200.0
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health: TextureProgressBar = $EnemyHealth
@export var fire_damge: float
var on_freeze = false
var freeze_damage = 0.2  # Damage per second
var freeze_duration = 1.0  # Total duration in seconds
var freeze_timer = 2 
var speed = 200
func _process(delta):
	process_fire(delta)
	process_health_check(delta)


func _physics_process(_delta: float) -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= detection_radius:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
	move_and_slide()



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
	if area is Freeze:
		on_freeze = true
		freeze_timer = 0.0
		enemy_health.value -= 20
		speed = 100
func take_lightning_damage(damage_amount: float) -> void:
	enemy_health.value -= damage_amount
func process_health_check(delta):
	if enemy_health.value <= 0:
		queue_free()
# In your Enemy script:
signal enemy_died

# In your enemy death function (wherever the enemy is destroyed):
func die():
	# Your existing death code...
	
	# Emit the signal before freeing
	emit_signal("enemy_died")
	queue_free()
