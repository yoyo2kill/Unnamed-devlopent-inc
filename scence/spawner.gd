extends Node2D

@onready var original_enemy = $Enemy
@export var player: Node2D  # Add this export for player reference
@export var num_enemies_to_spawn: int = 25

func _ready():
	# Print debug info to help diagnose issues
	print("Spawner initialized")
	print("Original enemy valid: ", is_instance_valid(original_enemy))
	print("Player valid: ", is_instance_valid(player))
	
	# Keep the original enemy as a template but hide it
	if is_instance_valid(original_enemy):
		original_enemy.visible = false
		print("Original enemy hidden and ready as template")
	
	# Start the repeating spawn cycle
	start_spawn_cycle()

func start_spawn_cycle():
	# Spawn the batch of enemies
	spawn_enemies()
	
	# Set up the timer to repeat the cycle after 300 seconds
	var spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer"
	spawn_timer.wait_time = 10.0
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(start_spawn_cycle)
	spawn_timer.start()

func spawn_enemies():
	if is_instance_valid(original_enemy) and is_instance_valid(player):
		print("Spawning", num_enemies_to_spawn, "enemies...")
		
		for i in range(num_enemies_to_spawn):
			var new_enemy = original_enemy.duplicate()
			new_enemy.visible = true
			
			# Set random position within viewport
			new_enemy.position = Vector2(
				randf_range(-500, get_viewport_rect().size.x), 
				randf_range(-100, get_viewport_rect().size.y)
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
			print("Set player reference on enemy")
			
			# Add to scene tree
			add_child(new_enemy)
			
			# Initialize path to player if the function exists
			if new_enemy.has_method("make_path"):
				new_enemy.make_path()
				print("Called make_path() on enemy")
			
		print("Successfully spawned", num_enemies_to_spawn, "enemies")
	else:
		printerr("Error: Original Enemy node not found or Player node not found!")
		if not is_instance_valid(original_enemy):
			printerr("  - Original enemy is not valid. Make sure you have an Enemy node as a child of the spawner.")
		if not is_instance_valid(player):
			printerr("  - Player is not valid. Make sure to set the player reference in the Inspector.")
