extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var  FIREBALL = preload("res://scence/fireball.tscn")
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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

#yotam is gay

func _input(event: InputEvent) -> void:
	if texture_progress_bar.value >= 100:
		if event.is_action_pressed("spell1"):
			texture_progress_bar.value -= 100
			shoot()

func shoot():
	var fireball = FIREBALL.instantiate()
	
	fireball.position = position
	fireball.fireball_dir = (position - get_global_mouse_position()).normalized()
	get_parent().add_child(fireball)
	
	
