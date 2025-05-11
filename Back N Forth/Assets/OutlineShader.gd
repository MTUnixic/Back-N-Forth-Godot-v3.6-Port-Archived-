extends Control

export (bool) var apply_saturation = false
func _ready():
	Global.ShaderPort = $Viewport
	var viewport_texture = $Viewport.get_texture()
	$Texture.texture = viewport_texture

func _process(delta):
	if apply_saturation:
		if Global.Escaping:
			$Texture.material.set_shader_param("saturation", 0.85)
		else:
			$Texture.material.set_shader_param("saturation", 1.66)
