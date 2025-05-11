extends Node2D

export (bool) var Stop_Player = false
var can_teleport = true
onready var Portal_B = $Portal_B
onready var Portal_A = $Portal_A
onready var sound = $TeleportSFX
var Body = null
var smootheffect = 0

func _process(delta):
	if smootheffect != 0:
		smootheffect = lerp(smootheffect, 0, 5 * delta)
		$Portal_A/Texture.material.set_shader_param("difference", smootheffect)
		$Portal_B/Texture.material.set_shader_param("difference", smootheffect)

func _on_HitboxA_body_entered(body):
	if can_teleport:
		sound.play()
		smootheffect = 1
		can_teleport = false
		$Cooldown.start()
		if body.name == "Blink":
			var direction = Vector2(-cos(Portal_B.rotation), -sin(Portal_B.rotation)).normalized()
			body.velocity = direction * body.velocity.length() * 0.7
			if body.Current_State == body.States.RUNNING:
				body.Moves.append("Sprinting_Jump")
			Body = body
		body.global_position = Portal_B.global_position

func _on_HitboxB_body_entered(body):
	if can_teleport:
		sound.play()
		smootheffect = 1
		can_teleport = false
		$Cooldown.start()
		print(body.name)
		if body.name == "Blink":
			var direction = Vector2(-cos(Portal_A.rotation), -sin(Portal_A.rotation)).normalized()
			body.velocity = direction * body.velocity.length() * 0.7
			if body.Current_State == body.States.RUNNING:
				body.Moves.append("Sprinting_Jump")
			if Stop_Player:
				body.can_move = false
			Body = body
		body.global_position = Portal_A.global_position

func _on_Cooldown_timeout():
	can_teleport = true
	if Body:
		Body.can_move = true
