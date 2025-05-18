extends Panel

var time: float = 300.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0

func _process(delta) -> void:
	time -= delta
	msec = fmod(time, 1) * 100
	seconds = fmod (time, 60)
	minutes = fmod (time, 3600) / 60
	$Minutes.text = "%02d:" % minutes
	$Seconds.text = "%02d:" % seconds
	$Msec.text = "%02d" % msec
