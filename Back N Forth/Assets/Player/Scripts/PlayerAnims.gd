extends AnimatedSprite

func _flash():
	material.set_shader_param("active", true)
	$FlashTimer.start()

func _on_FlashTimer_timeout():
	material.set_shader_param("active", false)
