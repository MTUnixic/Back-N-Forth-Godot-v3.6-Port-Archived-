extends Control

onready var tween = $Tween
func _ready():
	Global.EscapeScreen = self
func _flash():
	tween.stop_all() 
	tween.interpolate_property($Panel/Label, "self_modulate:a", 1.0, 0.0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)  
	tween.interpolate_property($Panel, "self_modulate:a", 1.0, 0.0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)  
	tween.start()
