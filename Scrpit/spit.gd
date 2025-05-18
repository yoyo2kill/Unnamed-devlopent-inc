extends Area2D

@export var speed = 200.0
@export var damage = 1
@export var lifetime = 5.0  # Seconds until bullet disappears

var direction = Vector2.ZERO  # Will be set by shooter
var source = null  # Who fired this bullet

func _ready():
	# Set up lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_timeout)
	add_child(timer)
	timer.start()
	
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	
	# Rotate bullet to match direction
	rotation = direction.angle()

func _physics_process(delta):
	# Move in the specified direction
	position += direction * speed * delta

func _on_body_entered(body):
	# Don't damage the source of the bullet
	if body == source:
		return
		
	# Check if we hit the player
	if body.is_in_group("player"):
		# Call damage function on player if it exists
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	# Check if we hit another enemy
	elif body.get_script() == source.get_script():
		# Skip damaging other enemies of the same type
		return
	
	# Delete the bullet on impact
	queue_free()

func _on_lifetime_timeout():
	queue_free()  # Remove bullet after lifetime expires
