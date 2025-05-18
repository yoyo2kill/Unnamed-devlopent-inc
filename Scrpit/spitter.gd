extends CharacterBody2D
class_name spitter
@onready var enemy_health: TextureProgressBar = $EnemyHealth
# Enemy properties
@export var SPEED = 50.0

@export var detection_radius = 300.0
@export var shooting_distance = 200.0
@export var bullet_speed = 200.0
@export var fire_rate = 1.5  # Shots per second
var on_fire = false
var fire_damage = 1  # Damage per second
var fire_duration = 1.0  # Total duration in seconds
var fire_timer = 0.0  # Current timer
# Bullet scene - you need to create a bullet scene and assign it here
@export var bullet_scene: PackedScene
var on_freeze = false
var freeze_damage = 0.2  # Damage per second
var freeze_duration = 1.0  # Total duration in seconds
var freeze_timer = 2 
var speed = 200
# References
var player = null
var can_shoot = true

# Called when the node enters the scene tree for the first time
func _ready():
	# Find the player at the start
	player = get_tree().get_first_node_in_group("player")
	# Set up shooting timer
	var timer = Timer.new()
	timer.wait_time = 1.0 / fire_rate
	timer.one_shot = false
	timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(timer)
	timer.start()

# Called every frame
func _physics_process(delta):
	if player == null:
		return
	
	# Calculate distance to player
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player is within detection radius
	if distance_to_player <= detection_radius:
		# Move towards player if too far to shoot
		if distance_to_player > shooting_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * SPEED
		else:
			# Stop moving when in shooting range
			velocity = Vector2.ZERO
			
		# Rotate to face player
	
		# Shoot if we can
		if can_shoot and distance_to_player <= shooting_distance:
			shoot()
	else:
		# Stop moving if player not detected
		velocity = Vector2.ZERO
	
	# Apply movement
	move_and_slide()

# Function to shoot bullets
func shoot():
	if bullet_scene == null:
		push_error("Bullet scene not assigned to enemy!")
		return
	
	can_shoot = false
	
	# Instance the bullet
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	# Calculate direction to player
	var direction = (player.global_position - global_position).normalized()
	
	# Set bullet properties
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet.damage = 1
	bullet.source = self  # Useful to prevent enemies from damaging each other
	
	# Add bullet to scene
	get_tree().current_scene.add_child(bullet)

# Timer callback to reset shooting ability
func _on_shoot_timer_timeout():
	can_shoot = true

func process_fire(delta):
	if on_fire:
		fire_timer += delta
		if fire_timer >= fire_duration:
			on_fire = false
			fire_timer = 0.0
		else:
			enemy_health.value -= 1.0
func _process(delta):
	process_fire(delta)
	process_health_check(delta)



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Fireball:
		on_fire = true
		fire_timer = 0.0
		enemy_health.value -= 20
	if area is Freeze:
		on_freeze = true
		freeze_timer = 0.0
		enemy_health.value -= 20
		speed = 100

func process_health_check(delta):
	if enemy_health.value <= 0:
		queue_free()
