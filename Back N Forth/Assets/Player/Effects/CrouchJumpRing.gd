extends AnimatedSprite

var vel = null
var rotatevel = false
func _ready():
	playing = true
func _process(delta):
	if not rotatevel:
		vel = get_parent().get_node("Blink").velocity
		rotation = atan2(vel.y,vel.x) + 1.57
		rotatevel = true
	position += Vector2(sin(rotation),cos(rotation)) * 2 if rotation > -0.1 and rotation < 0.1 else  Vector2(sin(rotation),cos(rotation)) * -2
func _on_CrouchJumpRing_animation_finished():
	queue_free()
