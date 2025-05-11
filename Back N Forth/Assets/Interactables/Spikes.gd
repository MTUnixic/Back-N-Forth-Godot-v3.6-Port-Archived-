extends Area2D

func _on_Hurtbox_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead:
		Global.Blink.die("Spike")
