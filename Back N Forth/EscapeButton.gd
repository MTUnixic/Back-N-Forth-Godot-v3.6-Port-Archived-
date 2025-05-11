extends Area2D

onready var AnimSprite = $AnimatedSprite

func _on_EscapeButton_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead:
		if not Global.Escaping:
			Global.Respawn_Point = global_position
			Global.Current_Checkpoint = self
			var text = preload("res://Assets/Player/Effects/CheckpointText.tscn").instance()
			$AnimatedSprite/TriggerSound.play()
			get_parent().add_child(text)
			text.global_position = Global.Blink.global_position
			Global.EscapeScreen._flash()
			Global.Music_player._play_escape()
			Global.Escaping = true
		AnimSprite.play("Pressed")
		$AnimatedSprite/Pressed.play()
func _on_EscapeButton_body_exited(body):
	if body.name == "Blink" and not Global.Blink.dead:
		AnimSprite.play("NotPressed")
		$AnimatedSprite/Unpressed.play()
