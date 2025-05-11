extends AnimatedSprite

func _on_Timer_timeout():
	queue_free()
func set_color(color):
	if color == "green":
		self_modulate = "5338ff00"
		material.set_shader_param("tint_color", Color8(44, 255, 0))
	elif color == "red":
		self_modulate = "53ff0000"
		material.set_shader_param("tint_color", Color8(255, 0, 0))
	elif color == "blue":
		self_modulate = "5300e7ff"
		material.set_shader_param("tint_color", Color8(0, 70, 255, 255))
	elif color == "purple":
		self_modulate = "535920ff"
		material.set_shader_param("tint_color", Color8(89, 32, 255, 255))
	# Don't touch this
	material.set_shader_param("difference", 1)
	$Tween.interpolate_property(self,"self_modulate:a",1.0,0.0,0.5,3,1)
	
	$Tween.start()
