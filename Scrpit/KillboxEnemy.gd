extends Area2D

# Reference to the health controller node
var health_controller = null

var damage = false
var damage_cooldown = 0
var can_damage = true

func _ready():
	# Defer finding the health controller to after the scene is fully loaded
	call_deferred("find_health_controller")

func find_health_controller():
	# Wait one frame to make sure everything is loaded
	await get_tree().process_frame
	
	# Check if player has the health controller directly
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("player") or body.name.to_lower().contains("player"):
			# Try to find health controller on player
			if body.has_node("HealthController"):
				health_controller = body.get_node("HealthController")
				print("Found health controller on player")
				return
	
	# Try using the group (most reliable)
	var health_controllers = get_tree().get_nodes_in_group("health_controller")
	if health_controllers.size() > 0:
		health_controller = health_controllers[0]
		print("Found health controller via group")
		return
	
	print("ERROR: Health controller not found! Please add it to the 'health_controller' group")
	print("Current enemy path: ", get_path())
func _process(delta: float) -> void:
	_process_1(delta)
	_process_2(delta)
	
# This triggers when the player enters the enemy's damage area
func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		print("Player detected in damage area")
		damage = true
		
		# Try to find health controller on the player if we don't have it yet
		if not health_controller and body.has_node("HealthController"):
			health_controller = body.get_node("HealthController")
	
func _process_2(delta: float) -> void:
	if damage_cooldown > 0:
		damage_cooldown -= delta
		if damage_cooldown <= 0:
			can_damage = true
	
	if damage == true and can_damage:
		if health_controller != null:
			# Use the damage_player method instead of directly accessing current_heart
			health_controller.damage_player(1)
			
			# Apply cooldown to prevent multiple hits too quickly
			damage_cooldown = 1.0  # 1 second cooldown
			can_damage = false
		else:
			# Try to find it again if it wasn't found initially
			find_health_controller()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		damage = false# Find the health controller in the scene
	health_controller = get_node("/root/Main/HealthController")
	# If you can't find it with that path, you may need to adjust the path
	# Or use another method to get a reference to it



func _process_1(delta: float) -> void:
	if damage == true:
		if health_controller != null:
			health_controller.current_heart -= 0
			health_controller.update_heart_num()
		else:
			print("Health controller not found!")
