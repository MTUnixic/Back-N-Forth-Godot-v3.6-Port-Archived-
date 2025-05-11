extends Control

onready var collectocounter = $CollectoFruit 

func _process(delta):
	collectocounter.text = str(Global.Collectable)
