extends Area2D

var rng = RandomNumberGenerator.new()
func _ready():
	Global.Respawn_Point = global_position

func _process(delta):
	if Global.Escaping:
		$OrbSprite.play("Open")
		$ButtonSprite.visible = true
		if get_overlapping_bodies().has(Global.Blink) and Input.is_action_pressed("Up Key") and not Global.End_game:
			Global.End_game = true
			Global.End_Type = "Escaped"
			Global.ResultsScreen._triggertext()
			Global.Escaping = false
			Global.Music_player.stop_music()
	else:
		$ButtonSprite.visible = false
		$OrbSprite.play("Closed")
func _physics_process(delta):
	yield(get_tree(),"idle_frame")
	rng.randomize()
	scale.x = lerp(scale.x,rng.randf_range(0.8,1),10 * delta)
	scale.y = lerp(scale.y,rng.randf_range(0.8,1),10 * delta)
