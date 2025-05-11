extends Camera2D

const SCREEN_SIZE := Vector2(1024, 600)
var cur_screen := Vector2(0, 0)

export var follow_speed: float = 5.0
export var y_offset: float = -140  # Increased offset to keep the camera higher
export var randomStrength: float = 1.3
export var shakeFade: float = 10.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready():
	yield(get_tree(), "idle_frame")
	global_position = Global.Blink.global_position + Vector2(0, y_offset)
	reset_smoothing()

func _physics_process(delta):
	if not Global.Blink.dead:
		var target_position = Global.Blink.global_position + Vector2(0, y_offset)
		global_position = lerp(global_position, target_position, follow_speed * delta)

func update_cam_no_smooth():
	global_position = Global.Blink.global_position + Vector2(0, y_offset)
	reset_smoothing()

func apply_shake():
	randomStrength = 10
	shake_strength = 6

func _process(delta):
	if Global.shakecam:
		apply_shake()
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
