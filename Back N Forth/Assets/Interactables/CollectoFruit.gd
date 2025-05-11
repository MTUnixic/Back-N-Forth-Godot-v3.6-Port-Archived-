extends Position2D

var left_alone = true
func _ready():
	$CollectoFruitAnim.play("Float_Idle")

func _on_PlayerDetect_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead:
		if left_alone == true:
			left_alone = false
			$TriggerSound.play()
			$CollectoFruitAnim.play("Touched")
			Global.Collectable += 1
			print(Global.Collectable, left_alone)
