extends CharacterBody2D
@onready var coldown_timer = $"coldown timer"
@export var inv: Inv
var dash_timer = 2
var SPEED = 300.0
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

	if event.is_action_pressed("ui_select") and is_ready:
		dash()
func shoot():
	var fireball = FIREBALL.instantiate()

	fireball.position = position
	# Fix direction calculation - this should point FROM player TO mouse
	fireball.fireball_dir = (get_global_mouse_position() - position).normalized()
	get_parent().add_child(fireball)
func collect(item):
	inv.insert(item)

func dash():
	$Timer.start()
	SPEED = 1000
	is_ready = false
	coldown_timer.start()

var is_ready = true


func _on_timer_timeout() -> void:
	SPEED = 300


func _on_coldown_timer_timeout() -> void:
	is_ready = true
