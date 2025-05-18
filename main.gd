extends Control
class_name HealthController
var current_heart
var max_heart = 10
var invincible = false
var invincible_timer = 0
var invincible_duration = 3 # Duration of invincibility in seconds

# Healing ability variables
var heal_cooldown = 5.0 # Cooldown in seconds
var heal_cooldown_timer = 0.0 # Current cooldown timer
var heal_uses_remaining = 3 # Limited to 3 uses total
var heal_on_cooldown = false # Track if healing is on cooldown

@onready var heart_display = $HeartContainer # Reference to your HBoxContainer with hearts
# Optional: reference to player sprite for visual feedback during invincibility
var player_sprite = null

func _ready():
	current_heart = max_heart
	update_heart_num()
	# Add this node to the health_controller group for easy finding
	add_to_group("health_controller")
	
	# Try to find the player sprite for visual feedback
	if get_parent() and get_parent().has_node("Sprite") or get_parent().has_node("Sprite2D"):
		player_sprite = get_parent().get_node("Sprite") if get_parent().has_node("Sprite") else get_parent().get_node("Sprite2D")

func _physics_process(delta: float) -> void:
	# Handle invincibility timer
	if invincible == true:
		invincible_timer -= delta
		
		# Optional: make the player sprite blink during invincibility
		if player_sprite:
			player_sprite.visible = int(invincible_timer * 10) % 2 == 0
		
		if invincible_timer <= 0:
			invincible = false
			print("Invincibility ended")
			
			# Make sure player is visible when invincibility ends
			if player_sprite:
				player_sprite.visible = true
	
	# Handle heal cooldown timer
	if heal_on_cooldown:
		heal_cooldown_timer -= delta
		if heal_cooldown_timer <= 0:
			heal_on_cooldown = false
			print("Heal ability ready!")
	
	# Check for H key press to add hearts
	if Input.is_action_just_pressed("ui_h") or Input.is_key_pressed(KEY_H):
		try_heal()

func try_heal():
	# Check if we have uses remaining and not on cooldown
	if heal_uses_remaining > 0 and not heal_on_cooldown:
		# Add hearts
		current_heart = min(current_heart + 2, max_heart)
		update_heart_num()
		
		# Reduce remaining uses
		heal_uses_remaining -= 1
		
		# Start cooldown
		heal_on_cooldown = true
		heal_cooldown_timer = heal_cooldown
		
		print("Added 2 hearts! Current health: ", current_heart, 
			  " - Uses remaining: ", heal_uses_remaining,
			  " - On cooldown for: ", heal_cooldown, " seconds")
	elif heal_uses_remaining <= 0:
		print("No healing uses remaining!")
	elif heal_on_cooldown:
		print("Healing on cooldown! Ready in: ", heal_cooldown_timer, " seconds")

func update_heart_num():
	# Update the hearts display using the HBoxContainer's update_heart method
	if heart_display:
		heart_display.update_heart(current_heart)
	else:
		print("ERROR: HeartContainer not found in HealthController!")

func damage_player(amount):
	# Check if player is currently invincible
	if invincible == true:
		print("Player is invincible - no damage taken")
		
	else:
		current_heart -= 1
		update_heart_num()
		print("Player health: ", current_heart)
		invincible = true
		invincible_timer = invincible_duration
		print("Player invincible for ", invincible_duration, " seconds")
	# You can add game over logic here
	if current_heart <= 0:
		print("GAME OVER")
