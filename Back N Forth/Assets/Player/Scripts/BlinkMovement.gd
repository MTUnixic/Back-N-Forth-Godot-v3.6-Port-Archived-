extends KinematicBody2D

# Variables
var velocity = Vector2.ZERO
var extra_vel = Vector2.ZERO

# Tweakable Variables
export (int) var jump_height
export (int) var gravity
export (int) var walk_speed
export (int) var run_speed
export (float) var gravity_multiplier
export (float) var hyperfall_gravity
export (int) var crounch_jump_height
export (int) var wall_jump_x
export (int) var wall_jump_y
export (float) var wall_jump_delay = 0.1
export (float) var wall_slide_gravity
export (int) var verti_dash_x
export (float) var skid_timer_time = 0.2
export (int) var dive_speed = 750
export (float) var buffertime = 0.2
export (int) var sprintdash_power = 650

# Blink States
enum States{
	IDLE,            # 0
	WALKING,         # 1
	RUNNING,         # 2
	SKID,            # 3
	JUMPING,         # 4
	ENTER_FALL,      # 5
	FALL,            # 6
	HYPERFALL,       # 7
	CROUCH,          # 8
	VERTI_PREPARE,   # 9
	CROUCH_JUMP,     # 10
	CROUCH_CHARGE,   # 11
	WALLSLIDE,       # 12
	UP,              # 13
	WALLRUN,         # 14
	DIVE,            # 15
	SPRINTDASH       # 16
}

# State Var Resets
var SPRINT_VELOCITY_THRESHOLD: int = 750
var dead: bool = false
var Current_State = States.IDLE
var Last_State = States.IDLE
var Moves: Array = []
var wall_slide: bool = false
var floor_slide: bool = false
var hyper_fall: bool = false
var flip_left: bool = false
var can_move: bool = true
var verti_prepare: bool = false
var sprintdashing: bool = false
var air_time: int = 0
var skid_timer: float = 0.0
var skid_boost_timer: float = 0.0
var charge_timer: float = 0
var jumpbuffer_timer: float = 0.0
var wallrun: int = 0
var diving: bool = false
var clampedfallspeed: int = 1600
var jumpbuffered: bool = false
var buffertimer: float = 0.0
var wallsticktoslide: float = 0.0
var wallstickfx: bool = false


# Scene node references
onready var AnimSprite = $PlayerAnims
onready var Shadowray = $ShadowRayCast
onready var WallJumpTimer = $Timers/WallJumpTimer
onready var sprint_timer = $PlayerAnims/RunTimer
onready var dive_timer = $PlayerAnims/DiveTimer
onready var hyperfall_timer = $PlayerAnims/HyperfallTimer
onready var wallrun_timer = $PlayerAnims/WallrunTimer
onready var left_ray = $Left
onready var right_ray = $Right

# Sounds
onready var runsfx = $Sounds/Run
onready var walksfx = $Sounds/FootSteps
onready var jump_normal = $Sounds/Jump
onready var jump_extra = $Sounds/Jump_extra
onready var crouch_charge = $Sounds/Crouch_charge
onready var vertidash = $Sounds/VertiDash
onready var hyperfall_sfx = $Sounds/FastFall

# Sounds but variable
var step_sounds = [ 
	"res://Assets/Player/Sounds/Walking/walk1.wav",
	"res://Assets/Player/Sounds/Walking/walk2.wav",
	"res://Assets/Player/Sounds/Walking/walk3.wav",
	"res://Assets/Player/Sounds/Walking/walk4.wav",
	"res://Assets/Player/Sounds/Walking/walk5.wav" ]
var step_timer: float = 0.0
var step_delay: float = 0.3
var running_step_delay: float = 0.2 

# yes i do love these tysm :D
var make_ghost_effect: bool = false
var death_position = Vector2.ZERO
var got_to_peak_death_pos: bool = false
var death_rotate_timer: float = 0.0

func _ready() -> void:
	Global.Blink = self
	
	buffertime = 0
	jump_height *= -10
	wall_jump_y *= -10 * 1.1
	crounch_jump_height *= -10
	Last_State = Current_State
	
	yield(get_tree(),"idle_frame")
	Global.Music_player._play_main()
	_respawn()


# The entire process code
func _physics_process(delta) -> void:
	
	if States.CROUCH_CHARGE:
		velocity.x *= 1
	# Death check lmao
	if dead or Global.End_game:
		return

	if skid_boost_timer > 0 and can_move:
		skid_boost_timer -= delta

	# Movement Left Right Typ shi
	if Input.get_axis("Move Left", "Move Right") != 0 and can_move and Current_State != States.CROUCH or floor_slide and not Current_State == States.CROUCH_CHARGE:
		if not Current_State == States.CROUCH_CHARGE and not diving:

			if Current_State != States.RUNNING:
				velocity.x +=  walk_speed if Input.get_axis("Move Left","Move Right") > 0 else -walk_speed if is_on_floor() else walk_speed if Input.get_axis("Move Left","Move Right") > 0 else -walk_speed  * 0.65

			else:
				velocity.x +=  run_speed if Input.get_axis("Move Left","Move Right") > 0 else -run_speed if is_on_floor() else run_speed if Input.get_axis("Move Left","Move Right") > 0 else -run_speed  * 0.65
	
	# Last State func
	if not (wall_slide or Current_State in [States.JUMPING, States.ENTER_FALL, States.FALL]):
		Last_State = Current_State
	# Hyperfall + Wall
	if not wall_slide:
		wallsticktoslide = 0.0
		wallrun = false

		if hyper_fall:
			velocity.y += hyperfall_gravity * 20 * delta
		# Gravity
		else:
			var gravity_resistance = get_floor_normal() if is_on_floor() else Vector2.UP
			velocity -= gravity_resistance * gravity * 10 * delta
			# velocity.y += gravity * 10 * delta
	else:
		if not diving:
			if Last_State == States.RUNNING:
				wall_slide_gravity = -run_speed
				velocity.y = -run_speed * 5
				extra_vel.x = 0
				Current_State = States.WALLRUN
				wallrun = true
			else:
				wallstickfx == true
				wallsticktoslide += delta
				wall_slide_gravity = 60
				if extra_vel.x >= run_speed or extra_vel.x <= -run_speed:
					extra_vel.x = 60 if not flip_left else -60
				#velocity.y = 0
				if wallsticktoslide >= 0.3:
					velocity.y = clamp(velocity.y + wall_slide_gravity * 10 * delta,-300,200)
				else:
					velocity.y = 0
				wallrun = false

		if wallstickfx:
			make_ground_effect("WallStick")
			wallstickfx == false

# ALOT OF SHIT STARTS FROM HERE
	# Handles Jumping and buffers
	if air_time < 8: 
		if is_on_floor():
			preform_jump()
		else:
			jumpbuffered = true
			buffertimer = buffertime

	# Activates buffer timer
	if jumpbuffered:
		buffertimer -= delta
		if buffertimer <= 0.0:
			jumpbuffered = false

	# Executes jump if its buffered
	if jumpbuffered and is_on_floor():
		preform_jump()
		jumpbuffered = false

	# Wall-jump
	elif wall_slide and Input.is_action_just_pressed("Jump"):
		wall_slide = false
		can_move = false
		velocity.y = wall_jump_y
		extra_vel.x = wall_jump_x if flip_left else -wall_jump_x
		AnimSprite.scale.x *= -1
		WallJumpTimer.start(wall_jump_delay)
		Current_State = States.JUMPING
		jump_normal.play()
		jump_extra.play()

	# Sprint Dash
	if Current_State == States.RUNNING:
		if Input.is_action_just_pressed("Special") and Global.Stamina >= 2:
			velocity.x += sprintdash_power * 1.5
			Global.Stamina -= 2
			Current_State = States.SPRINTDASH
			sprintdashing = true
		else:
			sprintdashing = false
	
	# No idea what this does either
	if not velocity.y < 0 and not is_on_floor():
		velocity.y *= gravity_multiplier
	
	if velocity.y < -200 and Input.is_action_just_released("Jump") and not Moves.has("Down") and not wall_slide:
			velocity.y = jump_height / 2

	# Nice airborne movement
	if not is_on_floor():
		if not Moves.has("Sprinting_Jump"):
			velocity.x = clamp(velocity.x * 0.97, -450, 450) 
		else:
			velocity.x = clamp(velocity.x * 0.97, -790, 790)
	else:
		velocity.x = velocity.x * 0.88
	extra_vel.x = extra_vel.x * 0.88
	if skid_boost_timer > 0:
		extra_vel.x += 12 if flip_left else -12
	velocity = move_and_slide_with_snap(velocity + extra_vel,Vector2.DOWN, Vector2.UP,true,4,0.785)
	$Label.text = str(Current_State)

func _process(delta) -> void:
	velocity.y = min(velocity.y + gravity * delta, clampedfallspeed)
	
	# Detect dive input (you can map this to a key or button)
	if Input.is_action_just_pressed("Special") and not is_on_floor() and not diving and Global.Stamina >= 2:
		Global.Stamina -= 2
		diving = true
		velocity.y = -100  # Stop downward momentum temporarily
		extra_vel.x = dive_speed * (1 if not flip_left else -1)  # Apply horizontal speed based on direction
		AnimSprite.play("Dive")  # Assuming you have a dive animation
		hyperfall_sfx.play()
	#if diving and is_on_floor():
		#diving = false

	# Apply the horizontal velocity during the dive
	if diving:
		velocity.x += extra_vel.x * delta
		velocity.y = max(velocity.y, -150)  # Prevent falling too quickly

	# End dive when input is released
	if diving and is_on_floor():
		diving = false
		Current_State = States.FALL  # Return to fall state or another state as needed
	
	if Global.End_game:
		return

	if dead:
		death_rotate_timer += delta

		if death_rotate_timer >= 0.13:
			death_rotate_timer = 0.0
			AnimSprite.rotation_degrees -= 20
		
		$PlayerAnims/DeathAnimation.play("Death")
	else:
		right_ray.force_raycast_update()
		left_ray.force_raycast_update()

		if  not right_ray.is_colliding() and not left_ray.is_colliding():
			if skid_timer <= 0 and not verti_prepare and not wall_slide:
				if velocity.x != 0:
					flip_left = velocity.x < 0
		else:
			if right_ray.is_colliding():
				flip_left = false

			elif left_ray.is_colliding():
				flip_left = true

		if skid_timer <= 0:
			AnimSprite.scale.x = -1 if flip_left else 1

		if is_on_floor():
			AnimSprite.rotation = lerp_angle(AnimSprite.rotation, atan2(get_floor_normal().y,get_floor_normal().x) + PI / 2, 10 * delta)
			AnimSprite.position.y = lerp(AnimSprite.position.y,get_floor_normal().y + 10, 10 * delta)

		else:
			AnimSprite.position.y = 0
			AnimSprite.rotation = lerp_angle(AnimSprite.rotation, 0, 10 * delta)

		if is_on_floor():
			hyper_fall = false

			if is_on_floor() and not verti_prepare and not Current_State ==  States.CROUCH_CHARGE and not Current_State == States.SKID and (Input.is_action_pressed("Move Left") or Input.is_action_pressed("Move Right")):
				if not Input.is_action_pressed("Down") and not Input.is_action_just_pressed("Special") and not floor_slide and skid_timer <= 0:
					if Current_State != States.SKID:
						if Input.is_action_pressed("Run"):
							if not diving and Current_State != States.RUNNING and not Moves.has("Sprinting_Jump") and not Current_State == States.SKID:
								AnimSprite._flash()
								make_ground_effect("Dust")
								$Sounds/SonicEXE_Ding2.play()
								runsfx.play()
							Current_State = States.RUNNING

						else:
							Current_State = States.WALKING

				if velocity.x > 450 and Input.is_action_pressed("Move Left") or velocity.x < -450 and Input.is_action_pressed("Move Right"):
					if Current_State != States.SKID:
						$Sounds/Skid.play()
						$Sounds/Skid_extra.play()
						AnimSprite.scale.x *= -1
						skid_timer = skid_timer_time
						velocity.x = velocity.x - 500 if velocity.x > 0 else velocity.x + 500
						if Current_State == States.RUNNING:
							skid_boost_timer = 0.2
						Current_State = States.SKID
						make_ground_effect("Skid")

			# Handles Crouch Charging :D
			# Activates crouching that can be transitioned to crouch charging
			elif Input.is_action_pressed("Down") and is_on_floor() and not floor_slide:
				if Current_State != States.CROUCH:
					Current_State = States.CROUCH
				#if charge_timer >= 0.1:
				if Input.is_action_pressed("Special"):
					charge_timer += delta
					Current_State = States.CROUCH_CHARGE
					$PointerCenter.visible = true
			# Crouch charges the moment you let go
			elif not Input.is_action_pressed("Down") and is_on_floor() and not floor_slide and charge_timer > 0:
				charge_timer = 0.0
				Current_State = States.CROUCH_CHARGE
				do_crouch_charging()
			else:
				# Timer reset
				charge_timer = 0.0
				if not floor_slide and Current_State != States.SKID:
					Current_State = States.IDLE
			if is_on_floor() and Input.get_axis("Move Left","Move Right") != 0:
				if not Current_State in [States.CROUCH_CHARGE, States.CROUCH_JUMP]:
					floor_slide = false
			else:
				floor_slide = false
			if not diving and Input.is_action_pressed("Up Key") and Input.is_action_pressed("Special") and not (Input.is_action_pressed("Move Left") or Input.is_action_pressed("Move Right")):
					verti_prepare = true
			else:
				if not diving:
					if verti_prepare and Global.Stamina >= 3:
						Global.Stamina -= 3
						velocity.y = jump_height * 0.5
						extra_vel.x += -verti_dash_x if flip_left else verti_dash_x
						verti_prepare = false
						Current_State = States.WALKING
						vertidash.play()
					verti_prepare = false
		elif not wall_slide and not floor_slide and air_time > 15:
			if Input.is_action_pressed("Down") and air_time > 15 and not(is_on_floor() and velocity.y == 0):
				if not hyper_fall:
					hyperfall_sfx.play()
				hyper_fall = true
				Current_State = States.HYPERFALL
			elif not Current_State == States.FALL and Moves.has("Down") and not hyper_fall:
				Current_State = States.ENTER_FALL
			else:
				if not hyper_fall:
					Current_State = States.FALL
		elif not is_on_floor() and air_time < 4:
			if Current_State == States.RUNNING and not Moves.has("Sprinting_Jump"):
						Moves.append("Sprinting_Jump")

		if wall_slide:
			Current_State = States.WALLSLIDE
		if verti_prepare:
			Current_State = States.VERTI_PREPARE
			AnimSprite.self_modulate = lerp(AnimSprite.self_modulate,Color8(98, 98, 98),15 * delta)
		else:
			AnimSprite.self_modulate = lerp(AnimSprite.self_modulate,Color8(255, 255, 255),15 * delta)
		if Current_State == States.WALLRUN or wallrun:
			AnimSprite.play("WallRun")
		elif diving:
			Current_State = States.DIVE
		else:
			diving = false
			match Current_State:
				States.WALLSLIDE:
					if not Current_State == States.WALLRUN:
						AnimSprite.play("WallSlide")
					else:
						AnimSprite.play("WallRun")
				States.IDLE:
					AnimSprite.play("Idle")
				States.SKID:
					skid_timer -= delta
					if skid_timer <= 0:
						Current_State = States.IDLE
					else:
						AnimSprite.play("Skid")
				States.WALKING:
					if is_on_floor():
						AnimSprite.play("Walk")
					else:
						Current_State = States.FALL
				States.RUNNING:
					if is_on_floor():
						if Input.is_action_pressed("Down") and Input.is_action_pressed("Special"):
							AnimSprite.play("Crouch Charge")
							Current_State = States.CROUCH_CHARGE
						else:
							if abs(velocity.x) > SPRINT_VELOCITY_THRESHOLD:
								AnimSprite.play("Running")
							else:
								AnimSprite.play("Pre Run")
					else:
						Current_State = States.FALL
				States.JUMPING:
					AnimSprite.play("Jump")
				States.ENTER_FALL:
					AnimSprite.play("Enter Fall")
				States.FALL:
					AnimSprite.play("Fall")
				States.HYPERFALL:
					AnimSprite.play("Hyperfall")
				States.VERTI_PREPARE:
					AnimSprite.play("Pre Verti")
				States.CROUCH:
					AnimSprite.play("Crouch")
				States.UP:
					AnimSprite.play("Look Up")
				States.CROUCH_CHARGE:
					AnimSprite.play("Crouch Charge")
					$PointerCenter.visible = true
					if Input.is_action_pressed("Move Right") or Input.is_action_pressed("Move Left"):
						$PointerCenter.rotation_degrees = 0 + AnimSprite.rotation_degrees if Input.is_action_pressed("Move Right") else 180 + AnimSprite.rotation_degrees
					else:
						$PointerCenter.rotation_degrees = -90 + AnimSprite.rotation_degrees
				States.CROUCH_JUMP:
					AnimSprite.play("Crouch Jump")
		if Current_State == States.WALKING or Current_State == States.RUNNING or( Current_State == States.WALLRUN or wallrun ):
			update_step_sounds(delta)
		if not Current_State == States.CROUCH_CHARGE:
			$PointerCenter.visible = false

		Shadowray.cast_to = Vector2(0,9000)
		Shadowray.force_raycast_update()
		Shadowray.get_node("Sprite").global_position = Vector2(Shadowray.get_collision_point().x, Shadowray.get_collision_point().y + 4)
		$ShadowRayCast/Sprite.rotation = atan2(Shadowray.get_collision_normal().y,Shadowray.get_collision_normal().x) + PI / 2
		$ShadowRayCast/Sprite.position.x = Shadowray.get_collision_normal().x
		if not is_on_floor() and $WallSlideColl.get_overlapping_bodies().size() > 0 and not Current_State == States.CROUCH_JUMP and not Current_State == States.CROUCH_CHARGE and not Current_State == States.HYPERFALL and not Current_State == States.HYPERFALL and can_move:
			wall_slide = true
		else:
			wall_slide = false
		if skid_timer != 0 and Current_State != States.SKID:
			skid_timer = 0
		if sprint_timer.is_stopped() and (Current_State == States.RUNNING or (wallrun or Current_State == States.WALLRUN)) or Moves.has("Sprinting_Jump"):
			sprint_timer.start()
		if is_on_floor():
			if not Moves == []:
				Moves.clear()
			air_time = 0
		else:
			air_time += 1

	# Trail timers
	
		if dive_timer.is_stopped() and diving:
			dive_timer.start()
	
		if hyperfall_timer.is_stopped() and Current_State == States.HYPERFALL:
			hyperfall_timer.start()
	
		if wallrun_timer.is_stopped() and wallrun:
			wallrun_timer.start()

# ---= FUNCTIONS =------------
# don't touch these (cuz then i will touch you >:D)


func update_step_sounds(delta) -> void:
	var delay = step_delay if Current_State == States.WALKING else running_step_delay
	step_timer += delta
	if step_timer >= delay:
		walksfx.stream = load(step_sounds[randi() % step_sounds.size()])
		walksfx.play()
		step_timer = 0
	

func do_crouch_charging() -> void:
	if is_on_floor() and not floor_slide and Global.Stamina >= 1:
		Moves.append("Down")
		if Input.is_action_pressed("Move Left") or Input.is_action_pressed("Move Right") and Global.Stamina >= 2:
			Global.Stamina -= 2
			var angle = AnimSprite.rotation
			var jump_direction = Vector2(cos(angle), sin(angle))
			# velocity.y == -100
			velocity.y += jump_height
			extra_vel.x += jump_direction.x * -crounch_jump_height * 3 if Input.is_action_pressed("Move Right") else jump_direction.x * crounch_jump_height * 3
			Current_State = States.JUMPING
		else:
			Global.Stamina -= 1
			velocity.y += crounch_jump_height
			Current_State = States.CROUCH_JUMP
		crouch_charge.play()
		jump_extra.play()
		start_ghost_effect("green")

func preform_jump() -> void:
	if Current_State != States.DIVE and Input.is_action_pressed("Jump") and not Moves.has("Down") and not Moves.has("Jump") and not Input.is_action_pressed("Down") or not Moves.has("Jump") and floor_slide and Input.is_action_pressed("Jump"):
				velocity.y = jump_height
				if floor_slide:
					floor_slide = false
				if not wall_slide:
					if Current_State == States.RUNNING:
						Moves.append("Sprinting_Jump")
						velocity.x += -500 if flip_left else 500
					Current_State = States.JUMPING
					Moves.append("Jump")
					jump_normal.play()
					jump_extra.play()

func make_ground_effect(type: String) -> void:
	var effect = preload("res://Assets/Player/Effects/GroundEffects.tscn").instance()
	get_parent().add_child(effect)
	effect.global_position = global_position
	effect.rotation = AnimSprite.rotation 
	if type == "Skid":
		effect.change_parent = false
		effect.flip_h = false if flip_left else true
		effect.play("Skid")
		effect.position.x += -5 if flip_left else 5
		effect.position.y += 2
	elif type == "Dust":
		effect.change_parent = true
		effect.flip_h = true if flip_left else false
		effect.play("Dust")

func _on_AnimatedSprite_animation_finished() -> void:
	if not wall_slide:
		if Current_State == States.ENTER_FALL:
			Current_State = States.FALL
		if Current_State == States.JUMPING:
			Current_State = States.FALL

func start_ghost_effect(color: String) -> void:
	make_ghost_effect = true
	var ringeffect = preload("res://Assets/Player/Effects/CrouchJumpRing.tscn").instance()
	get_parent().add_child(ringeffect)
	ringeffect.position = position
	_make_effect(color)
	$Timers/GhostEffectAmount.start()
	$Timers/GhostEffectDelay.start()

func die(type: String) -> void:
	dead = true
	$Sounds/Death.play()
	if type == "Spike":
		AnimSprite.play("SpikeDeath")
	elif type == "Lava":
		AnimSprite.play("LavaDeath")
	else:
		AnimSprite.play("Death")
	death_position = position
	$BlinkCollisions.disabled
	$ShadowRayCast/Sprite.visible = false
	AnimSprite.scale.x = 1
	AnimSprite._flash()
	got_to_peak_death_pos = false
	$Timers/RespawnTimer.start()
	AnimSprite.rotation_degrees += 40
	var marker = preload("res://Assets/Player/Effects/Death_Mark.tscn").instance()
	marker.global_position = global_position
	get_parent().add_child(marker)
	remove_child(marker)

func _respawn() -> void:
	if Global.Stamina < 8:
		Global.Stamina = 8
	$PlayerAnims/DeathAnimation.stop(true)
	AnimSprite.rotation_degrees = 0
	$ShadowRayCast/Sprite.visible = true
	dead = false
	global_position = Global.Respawn_Point
	make_respawn_effect()
	$Sounds/Respawn.play()
	get_parent().get_node("Camera").update_cam_no_smooth()
	get_parent().get_parent().get_node("OutlineShader/CenterContainer/Viewport/Camera").update_cam_no_smooth()
	AnimSprite._flash()
	Current_State = States.FALL
	extra_vel = Vector2.ZERO 
	velocity = Vector2.ZERO

func make_respawn_effect() -> void:
	var effect = preload("res://Assets/Player/Effects/RespawnEffect.tscn").instance()
	effect.global_position = global_position
	get_parent().add_child(effect)

func _on_GhostEffectDelay_timeout() -> void:
	if make_ghost_effect and not dead:
		_make_effect("green")
		$Timers/GhostEffectDelay.start()

func _make_effect(color: String) -> void:
	var ghosteffect = preload("res://Assets/Player/Effects/PlayerEffect.tscn").instance()
	get_parent().get_parent().get_node("Back_Objects").add_child(ghosteffect)
	ghosteffect.position = position
	ghosteffect.scale.x = -1 if velocity.x < 0 else 1
	ghosteffect.animation = AnimSprite.animation
	ghosteffect.frame = AnimSprite.frame
	ghosteffect.set_color(color)

func _on_GhostEffectAmount_timeout() -> void:
	make_ghost_effect = false

func _on_WallJumpTimer_timeout() -> void:
	can_move = true

func _on_SprintTimer_timeout() -> void:
	if not dead and Current_State == States.RUNNING or Moves.has("Sprinting_Jump"):
		_make_effect("blue")

func _on_RespawnTimer_timeout() -> void:
	_respawn()

func _on_DiveTimer_timeout() -> void:
	if not dead and diving:
		Current_State == States.DIVE
		_make_effect("purple")

func _on_HyperfallTimer_timeout() -> void:
	if not dead and Current_State == States.HYPERFALL:
		Current_State == States.HYPERFALL
		_make_effect("red")

func _on_WallrunTimer_timeout():
	if not dead and Current_State == States.WALLRUN or wallrun:
		_make_effect("blue")
