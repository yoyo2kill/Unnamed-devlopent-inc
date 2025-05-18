extends Control

@onready var timer = $Timer

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	_wavestart()

func _wavestart():
	timer.start(5) 
	print("Wave started! Timer is running.")

func _on_timer_timeout():
	print("Time Out!")
	_wavestart()
