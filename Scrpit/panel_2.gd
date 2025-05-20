extends Panel

var wave_number = 1
var time_since_last_wave = 0.0
@onready var wave_spawner: Node2D = $"../../../WaveSpawner"
func _ready():
	update_wave_label()


func update_wave_label():
	$WaveLabel.text = "Wave %d" % wave_number





func _on_wave_timer_timeout() -> void:
	print("peepeepoopoo")
	wave_number += 1
	update_wave_label()
