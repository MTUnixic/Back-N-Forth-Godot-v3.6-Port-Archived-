extends KinematicBody2D

enum STATES {
	IDLE,
	DEATH
}

enum DIRECTION {
	LEFT,
	RIGHT
}

export (STATES) var Current_State
export (DIRECTION) var direction
export var speed: float = 0
var velocity: Vector2 = Vector2()
var gravity: float = 2000.0
var spawn_point = Vector2.ZERO
onready var Wall_raycast = $EnemySprite/HitWall
onready var Floor_raycast = $EnemySprite/HitFloor
func change_state(new_state):
	Current_State = new_state

func _process(delta):
	velocity.y += gravity * delta

	match Current_State:
		STATES.IDLE:
			$EnemySprite.play("Idle")
		STATES.DEATH:
			$EnemySprite.play("Death")

	$EnemySprite.scale.x = 0.5 if direction == DIRECTION.RIGHT else -0.5

	if Current_State != STATES.DEATH:
		velocity = move_and_slide(velocity)

func _on_StompCollision_body_entered(body):
	if body == Global.Blink and not Global.Blink.dead:
		change_state(STATES.DEATH)
		$Stomp.play()
		Global.Blink.velocity.y = Global.Blink.jump_height * 1.4

func _on_EnemySprite_animation_finished():
	if Current_State == STATES.DEATH:
		queue_free()

func _on_HurtBox_body_entered(body):
	print(Global.Blink.Current_State)
	if body == Global.Blink and Global.Blink.air_time < 5 and not Current_State == STATES.DEATH and not Global.Blink.Current_State == 13:
		Global.Blink.die("Enemy")
	elif Global.Blink.Current_State == 13:
		print("test")
		change_state(STATES.DEATH)
		$Stomp.play()
		Global.Blink.velocity.y = Global.Blink.jump_height
		Global.Blink.die("Enemy")
