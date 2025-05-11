extends Node2D

export (int) var Speed
onready var PointA = $PointA
onready var PointB = $PointB
onready var Platform = $Platform
var got_to_point_a = false
func _ready():
	Platform.position = PointA.position
	got_to_point_a = true
func _process(delta):
	if Platform.position.distance_to(PointA.position) < 5 and got_to_point_a == false:
		got_to_point_a = true
	elif Platform.position.distance_to(PointB.position) < 5 and got_to_point_a == true:
		got_to_point_a = false
		
	if got_to_point_a == false:
		Platform.position = lerp(Platform.position,PointA.position,Speed * delta)
	else:
		Platform.position = lerp(Platform.position,PointB.position,Speed * delta)
