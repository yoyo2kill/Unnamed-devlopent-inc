extends CharacterBody2D
class_name Player


@export var inv: Inv



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

func shoot():
	var fireball = FIREBALL.instantiate()
	
	fireball.position = position
	# Fix direction calculation - this should point FROM player TO mouse
	fireball.fireball_dir = (get_global_mouse_position() - position).normalized()
	get_parent().add_child(fireball)


@onready var LightningSpell = preload("res://scence/LightningSpell.tscn")

# Spell properties
@export var lightning_cooldown: float = 2.0
@export var lightning_mana_cost: int = 0

# Spell state
var can_cast_lightning = true
var mana = 100  # Starting mana

func _process(delta):
	# Check for lightning spell input
	if Input.is_action_just_pressed("Lightning") and can_cast_lightning and mana >= lightning_mana_cost:
		texture_progress_bar.value -= 250
		cast_lightning_spell()

func cast_lightning_spell():
	# Get the direction to cast (for example, towards mouse cursor)
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position
	
	# Create instance of the lightning spell
	var lightning = LightningSpell.instantiate()
	get_parent().add_child(lightning)
	
	# Cast the lightning from the player's position in the specified direction
	lightning.cast(global_position, direction)
	
	# Apply cooldown
	can_cast_lightning = false
	mana -= lightning_mana_cost
	
	# Start cooldown timer
	var cooldown_timer = get_tree().create_timer(lightning_cooldown)
	cooldown_timer.timeout.connect(func(): can_cast_lightning = true)
