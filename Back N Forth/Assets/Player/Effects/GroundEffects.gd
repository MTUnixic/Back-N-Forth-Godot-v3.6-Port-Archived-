extends AnimatedSprite

var change_parent = false
func _ready():
	if change_parent:
		get_parent().add_child(self)

func _on_GroundEffects_animation_finished():
	queue_free()
