extends Node2D

onready var Main = $Main
onready var Escapeism = $Escapeism
export (bool) var play_music = false
func _ready():
	Global.Music_player = self
func _play_escape():
	if play_music:
		Main.stop()
		Escapeism.play()
func _play_main():
	if play_music:
		Escapeism.stop()
		Main.play()
func stop_music():
	Escapeism.stop()
	Main.stop()
