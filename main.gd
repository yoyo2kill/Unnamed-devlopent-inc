extends Control
class_name HealthController
var current_heart
var max_heart = 10
var invincible = false
var invincible_timer = 0
var invincible_duration = 3 # Duration of invincibility in seconds
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
func _process(delta):
	# Handle invincibility timer
	if invincible == true:
		invincible_timer -= delta


		if invincible_timer <= 0:
			invincible = false
			print("Invincibility ended")

			# Make sure player is visible when invincibility ends
			if player_sprite:
				player_sprite.visible = true
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
		get_tree().change_scene_to_file("res://scence/game_over_screen.tscn")
