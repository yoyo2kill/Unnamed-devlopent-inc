extends Panel

var wave_number = 1
var time_since_last_wave = 0.0

func _ready():
	update_wave_label()

func _process(delta) -> void:
	time_since_last_wave += delta
	if time_since_last_wave >= 60.0:
		wave_number += 1
		update_wave_label()
		time_since_last_wave = 0.0

func update_wave_label():
	$WaveLabel.text = "Wave %d" % wave_number
