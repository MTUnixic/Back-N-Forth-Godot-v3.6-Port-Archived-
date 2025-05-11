extends Area2D

func _ready():
	$FloatAnim.play("Float")
func _on_Lava_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead:
		Global.Blink.die("Lava")
