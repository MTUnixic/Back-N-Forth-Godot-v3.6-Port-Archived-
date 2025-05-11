extends Position2D
var respawn_pos = Vector2()
func _ready():
	respawn_pos = global_position
	$CheckPointAnims.play("Float_Idle")
func _on_PlayerDetect_body_entered(body):
	if body.name == "Blink" and not Global.Blink.dead and Global.Current_Checkpoint != self:
		Global.Respawn_Point = respawn_pos
		Global.Current_Checkpoint = self
		visible = false
		var text = preload("res://Assets/Player/Effects/CheckpointText.tscn").instance()
		$TriggerSound.play()
		get_parent().add_child(text)
		text.global_position = Global.Blink.global_position
		
func _process(delta):
	if Global.Respawn_Point != respawn_pos:
		visible = true
