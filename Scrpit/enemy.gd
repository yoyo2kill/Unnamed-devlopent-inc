extends CharacterBody2D

class_name Duplicator

var time_remaining
var on_fire = false
var fire_damage = 50  # Damage per second
var fire_duration = 0.8  # Total duration in seconds
var fire_timer = 0.0  # Current timer

# Lightning effect variables
var is_shocked = false
var shock_duration = 3
var shock_timer = 0.0
var shock_slow_factor = 0.5  # Movement slowed by 50% when shocked (0.5 for 50% of original speed)

const speed = 200
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health: TextureProgressBar = $EnemyHealth
@export var fire_damge: float

func _process(delta):
	process_fire(delta)
	process_shock(delta)  # Process shock effect
	process_health_check(delta)

func _physics_process(delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	
	# Apply shock slow effect if shocked
	var current_speed = speed
	if is_shocked:
		current_speed *= shock_slow_factor
		# Debug print to verify shock effect is active
		print("Enemy is shocked! Speed reduced to: ", current_speed)
	
	velocity = dir * current_speed
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
			enemy_health.value -= fire_damage * delta

# Handle shock effect
func process_shock(delta):
	if is_shocked:
		shock_timer += delta
		
		# Visual pulse effect while shocked (optional)
		if int(shock_timer * 10) % 2 == 0:
			modulate = Color(0.7, 0.7, 1.2)  # Blue tint
		else:
			modulate = Color(0.8, 0.8, 1.1)  # Slightly lighter blue
			
		if shock_timer >= shock_duration:
			is_shocked = false
			shock_timer = 0.0
			modulate = Color(1, 1, 1)  # Reset color

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Fireball:
		on_fire = true
		fire_timer = 0.0
		enemy_health.value -= 20
	# Check for lightning projectile hit
	elif area.is_in_group("lightning") or area.get_parent().is_in_group("lightning") or area.name.begins_with("Lightning"):
		take_lightning_damage(30)  # Apply lightning damage

# This function will be called by the lightning effect
func take_lightning_damage(damage_amount: float) -> void:
	enemy_health.value -= damage_amount
	
	# Apply shock effect
	is_shocked = true
	shock_timer = 2.0  # Reset timer when applying shock
	
	# Visual feedback for being shocked
	modulate = Color(0.7, 0.7, 1.2)  # Blue tint
	# Optional: play shock animation or sound effect here

func process_health_check(delta):
	if enemy_health.value <= 0:
		queue_free()
