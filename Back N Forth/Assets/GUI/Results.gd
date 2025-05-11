extends Control

onready var tween = $Tween
onready var image = $Image

func _triggertext():
	if Global.End_Type == "Escaped":
		$Victory.play()
		image.texture = preload("res://Assets/GUI/Assets/EndOfDemo.png")
	elif Global.End_Type == "TimedOut":
		$Timeout.play()
		image.texture = preload("res://Assets/GUI/Assets/TimedOut.png")
	visible = true
	image.visible = true
	fade_in()
	$TimeUntilMenu.start()
func _ready():
	Global.ResultsScreen = self
	visible = false
	image.self_modulate = Color(1, 1, 1, 0)

func fade_in():
	tween.stop_all() 
	tween.interpolate_property(image, "self_modulate:a", 0.0, 1.0, 4.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)  
	tween.start()


func _on_TimeUntilMenu_timeout():
	print("Changing scene to MainMenu...")
	change_to_mainmenu()
func change_to_mainmenu():
	var next_scene = load("res://Assets/GUI/MainMenu.tscn").instance()
	next_scene.name = "MainMenu"
	$"/root".add_child(next_scene)
	get_parent().get_parent().queue_free()


func _on_EscapeTime_timeout():
	Global.Music_player.stop_music()
	Global.End_game = true
	Global.End_Type = "TimedOut"
	_triggertext()
	Global.Escaping = false
