extends Area2D

enum States { DEFAULT, TOUCH }
export (States) var Current_State

func _ready():
	Current_State = States.DEFAULT
	$TrampAnim.play("default")


func _on_Area2D_body_entered(body):
	if body == Global.Blink and not Global.Blink.dead:
		Global.Blink.velocity.y = Global.Blink.jump_height * 1.4
		Current_State = States.TOUCH
		$TrampAnim.play("touch")

func _on_Trampoline_body_exited(body):
	if Current_State == States.TOUCH:
		Current_State = States.DEFAULT


func _physics_process(delta):
	match Current_State:
		States.TOUCH:
			$TrampAnim.play("touch")
		States.DEFAULT:
			$TrampAnim.play("default")
