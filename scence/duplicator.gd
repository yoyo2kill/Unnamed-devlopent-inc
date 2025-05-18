extends CharacterBody2D

class_name enemy
@export var detection_radius = 500.0
@export var shooting_distance = 200.0
var time_remaining
var on_fire = false
var fire_damage = 50 # Damage per second
var fire_duration = 0.8 # Total duration in seconds
var fire_timer = 0.0 # Current timer

# Lightning effect variables
var is_shocked = false
var shock_duration = 3
var shock_timer = 0.0
var shock_slow_factor = 0.5 # Movement slowed by 50% when shocked (0.5 for 50% of original speed)

const SPEED = 150
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health: TextureProgressBar = $EnemyHealth
@export var fire_damge: float

# --- Duplicator Specific Variable ---
var can_duplicate = true # A flag to ensure it only duplicates once

func _process(delta):
	process_fire(delta)
	process_shock(delta)
	process_health_check(delta) # Call health check every frame

func _physics_process(delta: float) -> void:
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
			enemy_health.value -= fire_damage * delta

# Handle shock effect
func process_shock(delta):
	if is_shocked:
		shock_timer += delta

		# Visual pulse effect while shocked (optional)
		if int(shock_timer * 10) % 2 == 0:
			modulate = Color(0.7, 0.7, 1.2)
		else:
			modulate = Color(0.8, 0.8, 1.1)

		if shock_timer >= shock_duration:
			is_shocked = false
			shock_timer = 0.0
			modulate = Color(1, 1, 1)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Fireball:
		on_fire = true
		fire_timer = 0.0
		enemy_health.value -= 10
	elif area.is_in_group("lightning") or area.get_parent().is_in_group("lightning") or area.name.begins_with("Lightning"):
		take_lightning_damage(30)

func take_lightning_damage(damage_amount: float) -> void:
	enemy_health.value -= damage_amount
	is_shocked = true
	shock_timer = 2.0
	modulate = Color(0.7, 0.7, 1.2)

func process_health_check(delta):
	if enemy_health.value <= 0:
		if can_duplicate:
			duplicate_and_queue_free()
		else:
			die()

func duplicate_and_queue_free():
	if can_duplicate:
		can_duplicate = false

		var parent = get_parent()
		if parent:
			var duplicate1 = self.duplicate()
			var duplicate2 = self.duplicate()

			duplicate1.can_duplicate = false
			duplicate2.can_duplicate = false

			var duplicate1_health_bar = duplicate1.get_node("EnemyHealth") as TextureProgressBar
			var duplicate2_health_bar = duplicate2.get_node("EnemyHealth") as TextureProgressBar

			if is_instance_valid(duplicate1_health_bar):
				duplicate1_health_bar.value = enemy_health.max_value / 2
			if is_instance_valid(duplicate2_health_bar):
				duplicate2_health_bar.value = enemy_health.max_value / 2

			var spread_distance = 20
			var random_angle1 = randf_range(0, TAU)
			var random_angle2 = randf_range(0, TAU)

			duplicate1.global_position = global_position + Vector2(cos(random_angle1), sin(random_angle1)) * spread_distance
			duplicate2.global_position = global_position + Vector2(cos(random_angle2), sin(random_angle2)) * spread_distance

			parent.add_child(duplicate1)
			parent.add_child(duplicate2)
			

		queue_free() # And the original gets removed here
# In your Enemy script:
signal enemy_died

# In your enemy death function (wherever the enemy is destroyed):
func die():
	# Your existing death code...
	
	# Emit the signal before freeing
	emit_signal("enemy_died")
	queue_free()
