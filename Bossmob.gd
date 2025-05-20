extends CharacterBody2D
class_name BossMob

@export var num_enemies_to_spawn: int = 3 # How many of each type to try and spawn
@export var spawn_radius: float = 150.0 # Radius around the boss to spawn enemies
@export var player: Node2D # Reference to the player
@export var enemy_scene: PackedScene # The enemy scene to spawn
@export var duplicator_scene: PackedScene # Optional duplicator enemy scene
@export var spitter_scene: PackedScene
@export var speed_scene: PackedScene

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health := $EnemyHealth as TextureProgressBar
@onready var spawn_timer := $SpawnTimer as Timer
@onready var ground_pound_cooldown := $GroundPoundCooldown as Timer

# Phase system variables
enum BossPhase {NORMAL, ENRAGED, DESPERATE}
var current_phase = BossPhase.NORMAL
var phase_health_thresholds = [0.7, 0.3] # At 70% and 30% health

# Ground pound variables
var can_ground_pound = true
var SPEED = 75 # Adjust boss speed as needed

func _ready():
	if not is_instance_valid(player):
		# Try to find player in scene if not set
		player = get_tree().get_first_node_in_group("player")
	
	if is_instance_valid(player):
		makepath()
	
	# Create the spawn timer if it doesn't exist
	if not has_node("SpawnTimer"):
		var new_timer = Timer.new()
		new_timer.name = "SpawnTimer"
		new_timer.wait_time = 5.0 # Spawn enemies every 5 seconds
		new_timer.one_shot = false
		add_child(new_timer)
		spawn_timer = new_timer
		
	# Connect timer timeout signal
	if not spawn_timer.timeout.is_connected(self._on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# Create ground pound cooldown timer if it doesn't exist
	if not has_node("GroundPoundCooldown"):
		var gp_timer = Timer.new()
		gp_timer.name = "GroundPoundCooldown"
		gp_timer.wait_time = 15.0
		gp_timer.one_shot = true
		add_child(gp_timer)
		ground_pound_cooldown = gp_timer
	
	# Connect ground pound cooldown timer signal
	if not ground_pound_cooldown.timeout.is_connected(self._on_ground_pound_cooldown_timeout):
		ground_pound_cooldown.timeout.connect(_on_ground_pound_cooldown_timeout)
	
	# Start the spawn timer
	spawn_timer.start()

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		# Move towards player
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * SPEED
		move_and_slide()
		
		# Check if we should do a ground pound (only creates shockwaves now)
		if can_ground_pound:
			var distance_to_player = global_position.distance_to(player.global_position)
			if distance_to_player < 400:
				perform_ground_pound()

func makepath() -> void:
	if is_instance_valid(player) and nav_agent:
		nav_agent.target_position = player.global_position

func _on_timer_timeout():
	makepath()

func _on_spawn_timer_timeout():
	spawn_enemies_around()

func take_damage(amount: float):
	if is_instance_valid(enemy_health):
		enemy_health.value -= amount
		var current_health_percent = enemy_health.value / enemy_health.max_value
		
		# Check for phase transitions (more reliable checking)
		if current_phase == BossPhase.NORMAL and current_health_percent <= phase_health_thresholds[0]:
			transition_to_phase(BossPhase.ENRAGED)
		elif current_phase == BossPhase.ENRAGED and current_health_percent <= phase_health_thresholds[1]:
			transition_to_phase(BossPhase.DESPERATE)
		
		if enemy_health.value <= 0:
			# Last stand - spawn a bunch of enemies before dying
			spawn_enemies_around(6)  # More enemies as a last stand
			queue_free() # Remove the boss after it's defeated

func transition_to_phase(new_phase):
	print("Boss transitioning to phase: ", new_phase)
	current_phase = new_phase
	match new_phase:
		BossPhase.ENRAGED:
			print("Boss entering ENRAGED phase!")
			# Boss turns red, moves faster, spawns more frequently
			modulate = Color(1.5, 0.5, 0.5)
			SPEED = 150
			spawn_timer.wait_time = 8.0
			ground_pound_cooldown.wait_time = 2.5
			
			# Spawn enemies to mark phase change
			spawn_enemies_around(4)
			
		BossPhase.DESPERATE:
			print("Boss entering DESPERATE phase!")
			# Boss turns blue, moves even faster, spawns more frequently
			modulate = Color(0.5, 0.5, 2.0)
			SPEED = 200
			spawn_timer.wait_time = 4.5
			ground_pound_cooldown.wait_time = 1.5
			
			# Spawn a lot of enemies to mark phase change
			spawn_enemies_around(5)

func perform_ground_pound():
	can_ground_pound = false
	
	# Stop movement temporarily
	var original_speed = SPEED
	SPEED = 0
	
	# Create the shockwaves (projectiles only)
	create_shockwaves()
	
	# Restore speed
	SPEED = original_speed
	
	# Start cooldown
	ground_pound_cooldown.start()

func create_shockwaves():
	# Number of shockwaves depends on phase
	var num_directions = 8
	if current_phase == BossPhase.ENRAGED:
		num_directions = 12
	elif current_phase == BossPhase.DESPERATE:
		num_directions = 16
	
	for i in range(num_directions):
		var angle = TAU * i / num_directions
		create_shockwave(angle)

func create_shockwave(angle: float):
	# Create a shockwave projectile
	var max_distance = 500.0
	var speed = 600.0
	
	var line = Line2D.new()
	line.width = 50
	line.default_color = Color(1, 0.7, 0.2, 0.8)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.RIGHT * 10)  # Will be adjusted by transform
	get_parent().add_child(line)
	line.global_position = global_position
	line.rotation = angle
	
	# Add a hitbox to the shockwave
	var area = Area2D.new()
	area.position = Vector2(max_distance/2, 0)  # Position it along the line
	area.monitoring = true
	area.monitorable = true
	area.add_to_group("boss_attack")
	line.add_child(area)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(max_distance, 20)
	collision.shape = shape
	area.add_child(collision)
	
	# Make the area damage the player if it hits
	area.connect("body_entered", func(body):
		if body == player:
			# Deal damage to player - assuming player has a take_damage method
			if body.has_method("take_damage"):
				body.take_damage(15)  # Ground pound shockwave damage
			print("Player hit by shockwave!")
	)
	
	# Animate the shockwave
	var tween = create_tween()
	tween.tween_property(line, "scale", Vector2(max_distance/10, 1), max_distance/speed)
	tween.tween_property(line, "default_color", Color(1, 0.7, 0.2, 0), 0.3)
	tween.tween_callback(line.queue_free)

func _on_ground_pound_cooldown_timeout():
	can_ground_pound = true

func spawn_enemy_at_position(position: Vector2):
	var parent = get_parent()
	
	if not parent or not is_instance_valid(enemy_scene):
		return
	
	# Decide which enemy type to spawn
	var enemy_instance
	if randf() > 0.7 and is_instance_valid(duplicator_scene):  # 30% chance for duplicator if available
		enemy_instance = duplicator_scene.instantiate()
	if randf( ) > 0.6 and is_instance_valid(spitter_scene):
		enemy_instance = spitter_scene.instantiate()
	else:
		if randf() > 0.5:
			enemy_instance = enemy_scene.instantiate() 
		else:
			enemy_instance = speed_scene.instantiate()
	
	# Initialize the enemy
	enemy_instance.global_position = position
	
	# Set the player reference if the enemy has the property
	if enemy_instance.has_method("set_player") and is_instance_valid(player):
		enemy_instance.set_player(player)
	elif "player" in enemy_instance and is_instance_valid(player):
		enemy_instance.player = player
	
	# Add the enemy to the scene
	parent.add_child(enemy_instance)
	
	# Initialize enemy pathfinding if applicable
	if enemy_instance.has_method("makepath"):
		enemy_instance.makepath()

func spawn_enemies_around(override_count: int = 0):
	var count = override_count if override_count > 0 else num_enemies_to_spawn
	var parent = get_parent()
	
	if not parent:
		printerr("Boss has no parent to add enemies to!")
		return
	
	if not is_instance_valid(enemy_scene):
		printerr("No enemy scene assigned to boss!")
		return
	
	# Spawn the specified number of enemies
	for i in range(count):
		# Choose a random position around the boss
		var random_angle = randf_range(0, TAU) # Random angle in radians
		var spawn_distance = randf_range(spawn_radius * 0.5, spawn_radius)
		var spawn_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * spawn_distance
		
		spawn_enemy_at_position(spawn_position)
		print("Boss spawned enemy at:", spawn_position)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Fireball:
		enemy_health.value -= 20
	elif area.is_in_group("lightning") or area.get_parent().is_in_group("lightning") or area.name.begins_with("Lightning"):
		take_damage(30)
