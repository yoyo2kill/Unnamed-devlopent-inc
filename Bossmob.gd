extends CharacterBody2D

class_name BossMob

@export var num_enemies_to_spawn: int = 3 # How many of each type to try and spawn
@export var spawn_radius: float = 50.0 # Radius around the boss to spawn enemies
@export var player: Node2D # Reference to the player

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var enemy_health: TextureProgressBar = $EnemyHealth # Assuming it has a health bar

const speed = 100 # Adjust boss speed as needed

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func makepath() -> void:
	if is_instance_valid(player):
		nav_agent.target_position = player.global_position

func _on_timer_timeout():
	makepath()

func _ready():
	if is_instance_valid(player):
		makepath()
	# Start a timer to periodically spawn enemies
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 3.0 # Adjust the spawn interval as needed
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	spawn_enemies_around()

func take_damage(amount: float):
	if is_instance_valid(enemy_health):
		enemy_health.value -= amount
		if enemy_health.value <= 0:
			queue_free() # Remove the boss after it's defeated (no final spawn)

func spawn_enemies_around():
	var parent = get_parent()
	if not is_instance_valid(parent):
		printerr("Boss has no parent to find enemies!")
		return

	var enemy_nodes = parent.get_children().filter(func(node): return node is CharacterBody2D and node.has_method("set_player") and node != self)
	var duplicator_nodes = parent.get_children().filter(func(node): return node is CharacterBody2D and node.has_method("set_player") and node != self and "can_duplicate" in node)

	var spawned_count = 0

	# Try to "move" existing enemy nodes
	for i in range(num_enemies_to_spawn):
		if spawned_count >= num_enemies_to_spawn * 2: # Limit total spawned
			break
		if enemy_nodes.size() > 0:
			var random_enemy = enemy_nodes[randi() % enemy_nodes.size()]
			_reposition_enemy(random_enemy)
			spawned_count += 1

		if duplicator_nodes.size() > 0:
			var random_duplicator = duplicator_nodes[randi() % duplicator_nodes.size()]
			_reposition_enemy(random_duplicator)
			spawned_count += 1

func _reposition_enemy(enemy_node):
	var random_angle = randf_range(0, TAU)
	var spawn_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	enemy_node.global_position = spawn_position
	if enemy_node.has_method("makepath"):
		enemy_node.makepath() # Tell the repositioned enemy to re-target the player
	print("Boss repositioned an enemy to:", enemy_node.global_position)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Fireball:
		take_damage(20)
	elif area.is_in_group("lightning") or area.get_parent().is_in_group("lightning") or area.name.begins_with("Lightning"):
		take_damage(30)
