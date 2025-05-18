extends Node2D

@onready var original_enemy = $Enemy
@export var player: Node2D
@export var num_enemies_to_spawn: int = 10
@onready var original_duplicate = $Duplicator
@export var num_duplicates_to_spawn: int = 5 # Example number for duplicates

func _ready():
	print("Spawner initialized")
	setup_spawn(original_enemy, "Enemy", num_enemies_to_spawn, 5.0, 60.0, "spawn_enemies")
	setup_spawn(original_duplicate, "Duplicate", num_duplicates_to_spawn, 7.0, 75.0, "spawn_duplicates") # Different delays for example

func setup_spawn(template_node: Node2D, object_name: String, spawn_count: int, initial_delay: float, repeat_delay: float, spawn_function_name: String):
	if is_instance_valid(template_node):
		template_node.visible = false
		print("Original", object_name, "hidden and ready as template")

		var initial_delay_timer = Timer.new()
		initial_delay_timer.name = "Initial" + object_name + "SpawnDelay"
		initial_delay_timer.wait_time = initial_delay
		initial_delay_timer.one_shot = true
		add_child(initial_delay_timer)
		initial_delay_timer.timeout.connect(Callable(self, "start_" + spawn_function_name.replace("spawn_", "cycle_")).bind(spawn_count, template_node))
		initial_delay_timer.start()
		print("Initial", object_name, "spawn will occur in", initial_delay, "seconds.")
	else:
		printerr("Error: Original", object_name, "node not found!")

func start_cycle_enemies(count: int, template: Node2D):
	spawn_batch(template, count)
	var spawn_timer = Timer.new()
	spawn_timer.name = "EnemySpawnTimer"
	spawn_timer.wait_time = 60.0
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_batch.bind(template, count))
	spawn_timer.start()
	print("Repeating enemy spawn cycle started every 60 seconds.")

func start_cycle_duplicates(count: int, template: Node2D):
	spawn_batch(template, count)
	var spawn_timer = Timer.new()
	spawn_timer.name = "DuplicateSpawnTimer"
	spawn_timer.wait_time = 75.0
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_batch.bind(template, count))
	spawn_timer.start()
	print("Repeating duplicate spawn cycle started every 75 seconds.")

func spawn_batch(template_node: Node2D, count: int):
	if is_instance_valid(template_node) and is_instance_valid(player):
		var object_type = "unknown"
		if template_node == original_enemy:
			object_type = "enemy"
		elif template_node == original_duplicate:
			object_type = "duplicate"
		print("Spawning", count, object_type + "s...")

		for i in range(count):
			var new_object = template_node.duplicate()
			new_object.visible = true
			new_object.position = Vector2(
				randf_range(-500, get_viewport_rect().size.x),
				randf_range(-100, get_viewport_rect().size.y)
			)

			if new_object.has_node("NavigationAgent2D"):
				pass
			else:
				var nav_agent = NavigationAgent2D.new()
				nav_agent.name = "NavigationAgent2D"
				new_object.add_child(nav_agent)
				print("Added NavigationAgent2D to", object_type)

			if not new_object.has_node("PathUpdateTimer"):
				var timer = Timer.new()
				timer.name = "PathUpdateTimer"
				timer.wait_time = 0.5
				timer.autostart = true
				new_object.add_child(timer)
				if new_object.has_method("_on_timer_timeout"):
					timer.timeout.connect(new_object._on_timer_timeout)
				print("Added PathUpdateTimer to", object_type)

			new_object.player = player
			print("Set player reference on", object_type)
			add_child(new_object)
			if new_object.has_method("make_path"):
				new_object.make_path()
				print("Called make_path() on", object_type)
		print("Successfully spawned", count, object_type + "s")
	else:
		printerr("Error: Template node not found or Player node not found!")

func spawn_enemies(count: int): # Not directly used in the integrated approach
	pass

func spawn_duplicates(count: int): # Not directly used in the integrated approach
	pass
