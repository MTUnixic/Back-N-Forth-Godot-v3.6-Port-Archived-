extends Control

export (int) var EscapeTime
onready var EscapeTimer = $EscapeTime
onready var EscapeBar = $EscapeProgressBar
var smooth_time = 0
func _ready():
	EscapeTimer.wait_time = EscapeTime
	EscapeBar.max_value = EscapeTime
	EscapeBar.value = EscapeTime
func _process(delta):
	if Global.Escaping:
		if EscapeTimer.is_stopped():
			visible = true
			EscapeTimer.start()
		smooth_time = lerp(smooth_time,round(EscapeTimer.time_left),20 * delta)
		EscapeBar.value = smooth_time
		if EscapeTimer.time_left < 10:
			Global.shakecam = true
		else:
			Global.shakecam = false
	else:
		if not EscapeTimer.is_stopped():
			EscapeTimer.stop()
		visible = false


