extends TextureRect

func _process(delta):
	self_modulate.r8 = 255 - (((Global.Screen_y - -5) / (5 - -5)) * (255 - 208))
	material.set_shader_param("difference", Global.Screen_y / 50)	
	if Global.Escaping:
		material.set_shader_param("strength", 0.3)
		texture = preload("res://Assets/Map/BG/EscapeBG.svg")
	else:
		material.set_shader_param("strength", 0)
		texture = preload("res://Assets/Map/BG/Blue.svg")
