extends CharacterBody2D

@onready var laser: Node2D = $laser
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


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
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spell1"):
			laser.activate()
	else:
		laser.deactivate()
