extends Area2D
var touched_player = false
func _ready():
	scale = Vector2(0,0)
func _process(delta):
	if not touched_player:
		scale.x = lerp(scale.x,1,10*delta)
		scale.y = lerp(scale.y,1,10*delta)
	else:
		scale.x = lerp(scale.x,0,10*delta)
		scale.y = lerp(scale.y,0,10*delta)
		if scale.x <= 0.1:
			queue_free()
func _on_Death_Mark_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead:
		touched_player = true
