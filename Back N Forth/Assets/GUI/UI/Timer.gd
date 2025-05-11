extends Control

onready var timetxt = $Timer

var time = 0.0
var time_minutes = 0

func _ready():
	time = float(Global.SpeedTimer)

func _physics_process(delta):
	time += delta
	update_ui()

func update_ui():
	var hours = int(time / 3600) % 24
	var minutes = int(time / 60) % 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)

	Global.SpeedTimer = time
	if hours >= 1:
		timetxt.text = "MAX"
	else:
		timetxt.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
