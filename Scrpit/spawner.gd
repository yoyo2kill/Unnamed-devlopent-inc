extends Node2D

# Template enemies - you can add more template enemies as children of this node
@onready var original_enemy = $Enemy
@export var player: Node2D  # Add this export for player reference
# Round configuration
@export var max_rounds: int = 5
var current_round: int = 0
var active_enemies = 0  # Track number of active enemies
var next_spawn_timer = null  # Timer for next spawn cycle

# Round definitions - customize in the inspector
# Arrays must have the same number of elements for each round
@export var round_1_enemy_types: Array[String] = ["Enemy_spitter"]  # First round only spawns basic enemies
@export var round_1_enemy_counts: Array[int] = [3]          # Spawn 3 of them

@export var round_2_enemy_types: Array[String] = ["Enemy"]
@export var round_2_enemy_counts: Array[int] = [5]

@export var round_3_enemy_types: Array[String] = ["Enemy"]  # Add more enemy types as needed
@export var round_3_enemy_counts: Array[int] = [5]       # Spawn 5 basic

@export var round_4_enemy_types: Array[String] = ["Enemy"] 
@export var round_4_enemy_counts: Array[int] = [7]

@export var round_5_enemy_types: Array[String] = ["Enemy"]  # Final round
@export var round_5_enemy_counts: Array[int] = [10]    # Spawn 10 basic

func _ready():
	# Print debug info to help diagnose issues
	print("Spawner initialized")
	print("Original enemy valid: ", is_instance_valid(original_enemy))
	print("Player valid: ", is_instance_valid(player))
	
	# Hide all template enemies and tag them as templates
	for child in get_children():
		if child is CharacterBody2D or "Enemy" in child.name:
			child.visible = false
			# Add a metadata tag to identify template enemies
			child.set_meta("is_template", true)
			print(child.name + " hidden and ready as template")
	
	# Start the first round immediately
	start_next_round()
	
	# Create a timer to check if all enemies are dead
	create_enemy_check_timer()

func create_enemy_check_timer():
	var check_timer = Timer.new()
	check_timer.name = "EnemyCheckTimer"
	check_timer.wait_time = 1.0  # Check every second
	check_timer.one_shot = false
	add_child(check_timer)
	check_timer.timeout.connect(check_for_all_enemies_dead)
	check_timer.start()

func check_for_all_enemies_dead():
	# Count actual enemies (not templates)
	var actual_enemy_count = 0
	for child in get_children():
		# Only count visible enemies that aren't templates and have a visible property
		if (child is CharacterBody2D or ("Enemy" in child.name and child.get("visible") != null)) and child.visible and not child.has_meta("is_template"):
			actual_enemy_count += 1
	
	# Update our active enemies count (minus the templates)
	active_enemies = actual_enemy_count
	
	# If no active enemies and we have a pending timer, start the next round
	if active_enemies <= 0 and next_spawn_timer != null:
		print("All enemies eliminated. Starting next round...")
		next_spawn_timer.queue_free()
		next_spawn_timer = null
		$"Wave timer".start()

func enemy_died():
	active_enemies -= 1
	print("Enemy died. Remaining enemies: ", active_enemies)
	
	# If this was the last enemy, and we have a pending timer, we can start the next round immediately
	if active_enemies <= 0 and next_spawn_timer != null:
		print("All enemies eliminated. Starting next round...")
		next_spawn_timer.queue_free()
		next_spawn_timer = null
		$"Wave timer".start()



func queue_next_round():
	# Only create a new timer if one doesn't exist already
	if next_spawn_timer == null:
		next_spawn_timer = Timer.new()
		next_spawn_timer.name = "NextRoundTimer"
		next_spawn_timer.wait_time = 20.0
		next_spawn_timer.one_shot = true
		add_child(next_spawn_timer)
		next_spawn_timer.timeout.connect(func(): 
			if active_enemies <= 0:
				$"Wave timer".start()
				next_spawn_timer = null
			# Otherwise the check_for_all_enemies_dead function will handle it
		)
		next_spawn_timer.start()
		print("Next round queued for 20 seconds, or when all enemies are defeated")

func start_next_round():
	current_round += 1
	
	if current_round <= max_rounds:
		print("Starting Round ", current_round)
		spawn_enemies_for_current_round()
	else:
		print("All rounds completed!")
		# You could emit a signal here for game completion

func get_round_enemy_types(round_num: int) -> Array:
	match round_num:
		1: return round_1_enemy_types
		2: return round_2_enemy_types
		3: return round_3_enemy_types
		4: return round_4_enemy_types
		5: return round_5_enemy_types
		_: return []

func get_round_enemy_counts(round_num: int) -> Array:
	match round_num:
		1: return round_1_enemy_counts
		2: return round_2_enemy_counts
		3: return round_3_enemy_counts
		4: return round_4_enemy_counts
		5: return round_5_enemy_counts
		_: return []

func spawn_enemies_for_current_round():
	var enemy_types = get_round_enemy_types(current_round)
	var enemy_counts = get_round_enemy_counts(current_round)
	
	if enemy_types.size() != enemy_counts.size():
		printerr("Error: Enemy types and counts arrays must have the same size for round ", current_round)
		return
	
	print("Round ", current_round, " - Spawning enemies:")
	active_enemies = 0  # Reset the counter
	
	# Spawn each type of enemy according to the configuration
	for i in range(enemy_types.size()):
		var enemy_type = enemy_types[i]
		var enemy_count = enemy_counts[i]
		
		# Find the template enemy
		var template_enemy = null
		for child in get_children():
			if child.name == enemy_type:
				template_enemy = child
				break
		
		if template_enemy == null:
			printerr("Error: Template for enemy type '", enemy_type, "' not found!")
			continue
		
		print("  Spawning ", enemy_count, " of type ", enemy_type)
		
		# Spawn the specified number of this enemy type
		for j in range(enemy_count):
			spawn_enemy(template_enemy)
			active_enemies += 1
	
	print("Round ", current_round, " - Spawned ", active_enemies, " total enemies")
	
	# Queue the next round
	if current_round < max_rounds:
		queue_next_round()

func spawn_enemy(template_enemy):
	var new_enemy = template_enemy.duplicate()
	new_enemy.visible = true
	
	# Ensure this is NOT tagged as a template
	if new_enemy.has_meta("is_template"):
		new_enemy.remove_meta("is_template")
	
	# Set random position within specified rectangle (-1200, -650) to (690, 540)
	new_enemy.position = Vector2(
		randf_range(-1200, 690),
		randf_range(-650, 540)
	)
	
	# Make sure the new enemy has a NavigationAgent2D
	var nav_agent
	if new_enemy.has_node("NavigationAgent2D"):
		nav_agent = new_enemy.get_node("NavigationAgent2D")
	else:
		# Create a new NavigationAgent2D if needed
		nav_agent = NavigationAgent2D.new()
		nav_agent.name = "NavigationAgent2D"
		new_enemy.add_child(nav_agent)
		print("Added NavigationAgent2D to enemy")
	
	# Set up the timer for path updates if it doesn't exist
	if not new_enemy.has_node("PathUpdateTimer"):
		var timer = Timer.new()
		timer.name = "PathUpdateTimer"
		timer.wait_time = 0.5  # Update path every half second
		timer.autostart = true
		new_enemy.add_child(timer)
		
		# Connect the timer to a path update function
		# We need to ensure the enemy script has the correct methods
		if new_enemy.has_method("_on_timer_timeout"):
			timer.timeout.connect(new_enemy._on_timer_timeout)
		print("Added PathUpdateTimer to enemy")
	
	# Set the player reference on the enemy
	new_enemy.player = player
	
	# Connect to enemy's death signal
	if new_enemy.has_signal("enemy_died"):
		new_enemy.connect("enemy_died", Callable(self, "enemy_died"))
	else:
		# If no signal exists, we'll need to add this to the enemy script
		print("Warning: Enemy doesn't have 'enemy_died' signal. Add it to track enemy deaths!")
	
	# Add to scene tree
	add_child(new_enemy)
	
	# Initialize path to player if the function exists
	if new_enemy.has_method("make_path"):
		new_enemy.make_path()


func _on_wave_timer_timeout() -> void:
	start_next_round()
