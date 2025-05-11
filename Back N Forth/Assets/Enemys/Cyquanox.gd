extends KinematicBody2D

enum STATES { IDLE, DEATH, CLOSE, SPRINT, SKID }
enum DIRECTION { LEFT, RIGHT }

onready var Wall_raycast = $EnemySprite/HitWall
onready var Floor_raycast = $EnemySprite/HitFloor

export (STATES) var Current_State
export (DIRECTION) var movement_direction
export var speed: float = 200.0

var spawn_point = Vector2.ZERO
var velocity: Vector2 = Vector2()
var gravity: float = 2000.0


func change_state(new_state):
	Current_State = new_state

func _process(delta):
	velocity.y += gravity * delta

	match Current_State:
		STATES.IDLE:
			$EnemySprite.play("Walk")
			
			Wall_raycast.force_raycast_update()
			Floor_raycast.force_raycast_update()
			
			if Wall_raycast.is_colliding() or not Floor_raycast.is_colliding():
				flip_direction()
			
			if Current_State != STATES.DEATH:
				velocity.x = speed * (1 if movement_direction == DIRECTION.RIGHT else -1)
			else:
				velocity.x = 0
		
		STATES.DEATH:
			$EnemySprite.play("Death")
		
		STATES.CLOSE:
			velocity.x = 0
			$EnemySprite.play("Close")
			
		STATES.SPRINT:
			$EnemySprite.play("Sprint")
			
			Wall_raycast.force_raycast_update()
			Floor_raycast.force_raycast_update()
			
			if Wall_raycast.is_colliding() or not Floor_raycast.is_colliding():
				flip_direction()
				Current_State = STATES.IDLE
			if Global.Blink.dead:
				Current_State = STATES.IDLE
			
			if Current_State != STATES.DEATH:
				velocity.x = speed * 2.2 * (1 if movement_direction == DIRECTION.RIGHT else -1)
			else:
				velocity.x = 0
				
		STATES.SKID:
			$EnemySprite.play("Skid")
			if Current_State != STATES.DEATH:
				velocity.x = speed * 1 * (1 if movement_direction == DIRECTION.RIGHT else -1)
			else:
				velocity.x = 0

	$EnemySprite.scale.x = 2 if movement_direction == DIRECTION.RIGHT else -2

	if Current_State != STATES.DEATH:
		velocity = move_and_slide(velocity)


func flip_direction():
	if movement_direction == DIRECTION.RIGHT:
		movement_direction = DIRECTION.LEFT
	else:
		movement_direction = DIRECTION.RIGHT
	
	velocity.x = 0

func _on_StompCollision_body_entered(body):
	print(body)
	if body == Global.Blink and not Global.Blink.dead and Global.Blink.velocity.y < 100:
		change_state(STATES.DEATH)
		$SFX/Stomp.play()
		$SFX/ShellKick.play()
		Global.Blink.velocity.y = Global.Blink.jump_height

func _on_EnemySprite_animation_finished():
	match Current_State:
		STATES.DEATH:
			queue_free()
		STATES.CLOSE:
			$SFX/Whoosh.play()
			Current_State = STATES.SPRINT
		STATES.SKID:
			$SFX/Whoosh.play()
			flip_direction()
			Current_State = STATES.SPRINT

func _on_HurtBox_body_entered(body):
	if body == Global.Blink and Global.Blink.air_time < 8 and not Current_State == STATES.DEATH and not Global.Blink.Current_State == 12:
		Global.Blink.die("Enemy")
	elif Global.Blink.Current_State == 12 or Global.Blink.Current_State == 16:
		change_state(STATES.DEATH)
		$SFX/Stomp.play()
		$SFX/ShellKick.play()
		Global.Blink.velocity.y = Global.Blink.jump_height


func _on_DetectionRadius_body_entered(body):
	if body == Global.Blink and not Current_State == STATES.DEATH and not Global.Blink.Current_State == 12:
		if not Current_State in [STATES.SPRINT, STATES.SKID]:
			$SFX/Ding.play()
			Current_State = STATES.CLOSE

func _on_DetectionRadius_body_exited(body):
	if body == Global.Blink and not Current_State == STATES.DEATH and not Global.Blink.Current_State == 12:
		$SFX/Skid.play()
		Current_State = STATES.SKID
