extends Node2D

# Enum for the key/door color options
enum colour {
	red,
	blue,
	green
}

# Exported variables
export (colour) var KeyNDoor_color
export (bool) var set_respawn
export (float, 360) var Door_open_rotation
export (int) var Door_open_amount
export (int) var Open_distance_needed

# Onready and regular variables
onready var Door = $Door
var got_key: bool = false
var opening_door: bool = false
var playdoorsfx: bool = false
var door_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time
func _ready():
	door_pos = Door.position
	
	match KeyNDoor_color:
		colour.red:
			$Key/KeySprite.texture = preload("res://Assets/Interactables/Assets/Key1.svg")
			$Door/DoorSprite.texture = preload("res://Assets/Interactables/Assets/KeyDoor1.svg")
		colour.blue:
			$Key/KeySprite.texture = preload("res://Assets/Interactables/Assets/Key2.svg")
			$Door/DoorSprite.texture = preload("res://Assets/Interactables/Assets/KeyDoor2.svg")
		colour.green:
			$Key/KeySprite.texture = preload("res://Assets/Interactables/Assets/Key3.svg")
			$Door/DoorSprite.texture = preload("res://Assets/Interactables/Assets/KeyDoor3.svg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check if Blink is within the required distance to open the door
	if Door.global_position.distance_to(Global.Blink.global_position) < Open_distance_needed:
		if got_key:
			opening_door = true
		if not Global.Blink.dead and not playdoorsfx:
				$Door/DoorSprite/Open.play()
				playdoorsfx = true
		else:
			if not playdoorsfx and not Global.Blink.dead and not got_key:
				$Door/DoorSprite/Nuhuh.play()
				playdoorsfx = true
	else:
		if not opening_door:
			playdoorsfx = false
	
	# Handle door movement if the player has the key
	if got_key:
		if opening_door:
			var rad_rotation = deg2rad(Door_open_rotation)
			var target_position = Vector2(cos(rad_rotation), sin(rad_rotation)) * Door_open_amount
			Door.position = Door.position.linear_interpolate(target_position + door_pos, 10 * delta)
		else:
			Door.position = Door.position.linear_interpolate(door_pos, 10 * delta)
	else:
		$Key/KeySprite/KeyAnims.play("Float")

# Called when an object enters the trigger area
func _on_PlayerDetect_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead and not got_key:
		# Play the pickup animation and handle key acquisition
		$Key/KeySprite/KeyAnims.play("Pickup")
		$Key/KeySprite/TriggerSound.play()
		got_key = true
	
		# Handle checkpoint respawn logic
		if set_respawn:
			Global.Respawn_Point = $Key.global_position
			Global.Current_Checkpoint = self
			
			# Spawn checkpoint text effect
			var text = preload("res://Assets/Player/Effects/CheckpointText.tscn").instance()
			get_parent().add_child(text)
			text.global_position = Global.Blink.global_position
