extends Node2D

# Lightning spell properties
@export var damage = 300
@export var max_targets = 8
@export var lightning_color: Color = Color(0.5, 0.8, 1.0, 0.8)
@export var lightning_width: float = 5.0
@export var lightning_duration: float = 0.5
@export var max_distance: float = 500.0
@export_range(0, 10) var hit_detection_width: float = 3.0  # Width multiplier for hit detection

# Lightning effect variables
var target_points = []
var lightning_segments = []
var current_lifetime = 0.0
var lightning_active = false
var enemies_hit = []  # Track which enemies we've already hit

# Audio
var sfx_player: AudioStreamPlayer

func _ready():
	# Create a random seed for the lightning generation
	randomize()
	
	# Setup audio player for lightning sound
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	# Connect timeout signal
	$DurationTimer.wait_time = lightning_duration
	$DurationTimer.one_shot = true
	
	# Make the lightning vanish once the duration is over
	$DurationTimer.timeout.connect(func(): 
		lightning_active = false
		queue_free()
	)

func cast(from_position: Vector2, direction: Vector2):
	# Start the spell from the given position
	position = from_position
	
	# Reset list of hit enemies
	enemies_hit.clear()
	
	# Generate the lightning path
	generate_lightning_path(from_position, direction)
	
	# Check for targets
	check_for_targets()
	
	# Play lightning sound
	play_lightning_sound()
	
	# Start the duration timer
	lightning_active = true
	$DurationTimer.start()

func generate_lightning_path(start_pos: Vector2, direction: Vector2):
	# Clear any previous lightning
	target_points.clear()
	lightning_segments.clear()
	
	# Add the start point
	target_points.append(Vector2.ZERO)  # Local position (0,0)
	
	# Determine the end point in the direction with maximum distance
	var end_pos = direction.normalized() * max_distance
	
	# Generate zigzag path between start and end with more segments
	var segment_count = randi_range(8, 15)  # Increased number of segments
	for i in range(1, segment_count + 1):
		var t = float(i) / segment_count
		var main_point = end_pos * t
		
		# Add randomness to create the zigzag
		var rand_offset = Vector2(
			randf_range(-30, 30) * (1 - t),  # Less randomness as we approach the end
			randf_range(-30, 30) * (1 - t)
		)
		
		var point = main_point + rand_offset
		target_points.append(point)
	
	# Construct segments for drawing
	for i in range(len(target_points) - 1):
		lightning_segments.append([target_points[i], target_points[i + 1]])

func check_for_targets():
	var space_state = get_world_2d().direct_space_state
	
	# First, let's check along each segment with a wider collision detection
	for segment in lightning_segments:
		var segment_start = global_position + segment[0]
		var segment_end = global_position + segment[1]
		var segment_dir = (segment_end - segment_start).normalized()
		var segment_length = segment_start.distance_to(segment_end)
		
		# Create multiple raycasts along the width of the lightning
		for offset_multiplier in [-1.0, -0.5, 0.0, 0.5, 1.0]:
			# Calculate an offset perpendicular to the segment
			var perpendicular = segment_dir.rotated(PI/2) * lightning_width * hit_detection_width * offset_multiplier
			
			# Create physics query with the offset
			var query = PhysicsRayQueryParameters2D.create(
				segment_start + perpendicular, 
				segment_end + perpendicular
			)
			query.collide_with_areas = true
			query.collide_with_bodies = true
			query.collision_mask = 0xFFFFFFFF  # Check all collision layers (you can restrict this)
			
			var result = space_state.intersect_ray(query)
			if not result.is_empty():
				process_hit_result(result)
	
	# Second approach: Check for enemies in proximity to each point
	for point in target_points:
		var global_point = global_position + point
		
		# Create a shape query
		var shape_query = PhysicsShapeQueryParameters2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = lightning_width * hit_detection_width * 0.5
		shape_query.shape = circle_shape
		shape_query.transform = Transform2D(0, global_point)
		shape_query.collision_mask = 0xFFFFFFFF  # Check all collision layers
		shape_query.collide_with_areas = true
		shape_query.collide_with_bodies = true
		
		var results = space_state.intersect_shape(shape_query)
		for result in results:
			# For shape queries, we need to pass the global point as the hit position
			if not "position" in result:
				result["position"] = global_point
			process_hit_result(result)

func process_hit_result(result):
	var collider = result["collider"]
	
	# Skip if we've already hit this enemy
	if collider in enemies_hit:
		return
		
	# Check if the collider is an enemy - try multiple approaches
	var is_enemy = false
	
	# Method 1: Check by script name
	if collider is CharacterBody2D or collider is RigidBody2D or collider is Area2D:
		if collider.get_script():
			var script_name = collider.get_script().get_path().get_file()
			if "enemy" in script_name.to_lower():
				is_enemy = true
	
	# Method 2: Check by group
	if collider.is_in_group("enemies"):
		is_enemy = true
	
	# Method 3: Check by health component name pattern
	if collider.has_node("EnemyHealth") or collider.has_node("Health") or collider.has_node("HealthComponent"):
		is_enemy = true
	
	if is_enemy:
		# Apply lightning damage to enemy
		if collider.has_node("EnemyHealth"):
			var health_node = collider.get_node("EnemyHealth")
			# Try different approaches to apply damage
			if health_node.has_method("take_damage"):
				health_node.take_damage(damage)
			elif "value" in health_node:
				health_node.value -= damage
			elif "health" in health_node:
				health_node.health -= damage
		elif collider.has_method("take_damage"):
			collider.take_damage(damage)
		elif collider.has_method("hit"):
			collider.hit(damage)
		
		# Add to the list of hit enemies
		enemies_hit.append(collider)
		
		# Get position for the hit effect
		var hit_position = Vector2.ZERO
		if "position" in result:
			hit_position = result["position"]
		else:
			# If position isn't provided (e.g., in shape queries),
			# use the collider's position
			hit_position = collider.global_position
		
		# Create a hit effect at the impact point
		create_hit_effect(hit_position)
		
		# Check hit limit
		if enemies_hit.size() >= max_targets:
			return

func create_hit_effect(hit_position: Vector2):
	# Create a small explosion/spark at the hit point
	var hit_effect = CPUParticles2D.new()
	hit_effect.position = hit_position - global_position
	hit_effect.emitting = true
	hit_effect.one_shot = true
	hit_effect.explosiveness = 0.8
	hit_effect.amount = 20
	hit_effect.lifetime = 0.5
	hit_effect.color = lightning_color
	hit_effect.direction = Vector2.UP
	hit_effect.spread = 180
	hit_effect.gravity = Vector2.DOWN * 98
	hit_effect.initial_velocity_min = 50
	hit_effect.initial_velocity_max = 100
	add_child(hit_effect)
	
	# Auto-remove when done
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): hit_effect.queue_free(); timer.queue_free())
	timer.start()

func play_lightning_sound():
	# You'll need to load your own sound effect
	# sfx_player.stream = preload("res://path/to/lightning_sound.wav")
	sfx_player.volume_db = -10
	sfx_player.pitch_scale = randf_range(0.9, 1.1)
	sfx_player.play()

func _draw():
	if not lightning_active:
		return
	
	# Draw main lightning bolts
	for segment in lightning_segments:
		draw_line(segment[0], segment[1], lightning_color, lightning_width)
		
		# Add a few smaller branches to some segments
		if randf() < 0.3:  # 30% chance for a branch
			var mid_point = (segment[0] + segment[1]) / 2
			var branch_vector = (segment[1] - segment[0]).rotated(randf_range(-PI/4, PI/4))
			var branch_length = branch_vector.length() * randf_range(0.3, 0.5)
			var branch_end = mid_point + branch_vector.normalized() * branch_length
			
			draw_line(mid_point, branch_end, lightning_color, lightning_width * 0.7)
	
	# Draw a glow at each point of the lightning
	for point in target_points:
		var glow_size = lightning_width * 1.5
		draw_circle(point, glow_size, lightning_color.darkened(0.2))

func _process(delta):
	# Keep the lightning effect updating
	queue_redraw()
