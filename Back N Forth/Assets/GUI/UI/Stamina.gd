extends Control

onready var stamina = $Stamina
onready var rechargesfx = $AudioStreamPlayer
onready var glowupanim = $AnimationPlayer

var time_waiting = 0.0
var waiting = false

func _process(delta):

	if Global.Stamina < 8 and not waiting:
		waiting = true
		time_waiting = 0.0
	
	if Global.Stamina > 8:
		Global.Stamina = 8
		waiting = false

	if waiting:
		time_waiting += delta
		if time_waiting >= 1.7:
			Global.Stamina += 1
			animate()
			waiting = false

	else:
		if Global.Stamina == 0 or stamina.text == "0":
			glowupanim.play("Empty")
		elif Global.Stamina != 8:
			glowupanim.play("Glowup")
		else:
			glowupanim.play("Max")

	if stamina:
		stamina.text = str(Global.Stamina)

func animate():
	rechargesfx.play()
	glowupanim.play("Glowup")
