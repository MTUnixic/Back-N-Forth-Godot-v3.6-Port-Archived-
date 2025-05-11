extends Sprite



var treadmill_speed = 100.0
var wheel_radius = 32.0
var wheel_rotation_speed = 0.0

onready var wheel = $WheelNode
onready var shader_material = material 

func _process(delta):
	#position.x += treadmill_speed * delta
	
	wheel_rotation_speed = (treadmill_speed / wheel_radius) * (180.0 / 3.14159)
	if $WheelCollision.global_position.distance_to(Global.Blink.global_position) < 400 and global_position.y > Global.Blink.global_position.y:
		$WheelCollision/CollisionShape2D.disabled = false
		$WheelCollision.rotation_degrees += wheel_rotation_speed * 0.7 * delta
	else:
		$WheelCollision/CollisionShape2D.disabled = true
	var new_angle = shader_material.get_shader_param("angle") - (wheel_rotation_speed * delta)
	shader_material.set_shader_param("angle", new_angle)

