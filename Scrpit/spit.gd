extends Area2D

@export var speed = 200.0
@export var damage = 1
@export var lifetime = 5.0  # Seconds until bullet disappears

var health_controller_scene = preload("res://control.tscn")
var direction = Vector2.ZERO  # Will be set by shooter
var source = null  # Who fired this bullet

func _ready():
	# Set up lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(func(): queue_free())
	
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	# Move in the specified direction
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		# Instance the health controller or find existing one
		var health_controller = body.get_node_or_null("HealthController")
		
		# If no controller found, try to create one from the scene
		if health_controller == null:
			health_controller = health_controller_scene.instantiate()
			body.add_child(health_controller)
		
		# Now call the method on the instance
		if health_controller.has_method("damage_player"):
			health_controller.damage_player(damage)
		
		# Destroy bullet on hit
		queue_free()
