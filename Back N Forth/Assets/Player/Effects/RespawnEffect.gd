extends AnimatedSprite

func _on_RespawnEffect_animation_finished():
	queue_free()
