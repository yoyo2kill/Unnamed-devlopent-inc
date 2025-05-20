extends CharacterBody2D
class_name Player

var fill_cooldown = 3.0 # Cooldown in seconds for B key
var fill_cooldown_timer = 0.0 # Current cooldown timer
var fill_uses_remaining = 3 # Limited to 3 uses total
var fill_on_cooldown = false # Track if filling is on cooldown
@export var inv: Inv

var on_freeze = false
var freeze_damage = 0.2  # Damage per second
var freeze_duration = 1.0  # Total duration in seconds
var freeze_timer = 2 
@onready var FREEZE = preload("res://scence/freeze.tscn")  # Preload the freeze scene
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980  # Added gravity constant

@onready var FIREBALL = preload("res://scence/fireball.tscn")
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var updown := Input.get_axis("ui_up", "ui_down")
	if updown:
		velocity.y = updown * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if texture_progress_bar.value >= 100:
		if event.is_action_pressed("spell1"):
			texture_progress_bar.value -= 100
			shoot()
	if texture_progress_bar.value >= 200:
		if event.is_action_pressed("spell2"):  # Add new input for freeze spell
			texture_progress_bar.value -= 200  # Freeze costs less (75 instead of 100)
			
			
			shoot_freeze()
	if event.is_action_pressed("manapot"):
		try_fill_bar()
		
func try_fill_bar():
	# Calculate 3/4 threshold and 1/4 increment values
		var three_quarter_value = texture_progress_bar.max_value * 0.75
		var quarter_value = texture_progress_bar.max_value * 0.25
	
	# Check if progress bar is already at or above 75%
		if texture_progress_bar.value >= three_quarter_value:
			print("Progress bar already at or above 75%, not using a charge.")
			return
		
	# Check if we have uses remaining and not on cooldown
		if fill_uses_remaining > 0 and not fill_on_cooldown:
		# Add 1/4 to the current value, capped at max_value
			texture_progress_bar.value = min(texture_progress_bar.value + quarter_value, texture_progress_bar.max_value)
		
		# Reduce remaining uses
			fill_uses_remaining -= 1
		
		# Start cooldown
			fill_on_cooldown = true
			fill_cooldown_timer = fill_cooldown
		
		# Print debug info
			print("Added 1/4 to progress bar. Current value: ", texture_progress_bar.value, 
		 	 " - Uses remaining: ", fill_uses_remaining,
		 	" - On cooldown for: ", fill_cooldown, " seconds")
		elif fill_uses_remaining <= 0:
			print("No progress bar fill uses remaining!")
		elif fill_on_cooldown:
			print("Progress bar fill on cooldown! Ready in: ", fill_cooldown_timer, " seconds")

func shoot():
	var fireball = FIREBALL.instantiate()
	fireball.position = position
	# Fix direction calculation - this should point FROM player TO mouse
	fireball.fireball_dir = (get_global_mouse_position() - position).normalized()
	get_parent().add_child(fireball)
func shoot_freeze():
	var freeze = FREEZE.instantiate()
	freeze.position = position
	# Same direction calculation as fireball
	freeze.Freeze_dir = (get_global_mouse_position() - position).normalized()
	get_parent().add_child(freeze)
