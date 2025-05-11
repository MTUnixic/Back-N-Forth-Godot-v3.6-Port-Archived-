extends Control

var cache := []
func _ready():
	cache.push_back(load("res://Assets/GUI/MainMenu.tscn"))
	cache.push_back(load("res://Assets/Map/1_1.tscn"))
	Global.MainMenu = self
	$Audio.play()
func _on_Button_pressed():
	setup()
	SceneChanger.goto_scene("res://Assets/Map/Levels/Blue.tscn",self)
	$Audio.stop()

func setup():
	Global.cam = null
	Global.Screen_y = 0
	Global.Respawn_Point = null
	Global.Current_Checkpoint = null
	Global.Blink = null
	Global.ShaderPort = null
	Global.Escaping = false
	Global.shakecam = false
	Global.ResultsScreen = null
	Global.FailScreen = null
	Global.End_game = false
	Global.End_Type = "Escaped"
	Global.MainMenu = null
