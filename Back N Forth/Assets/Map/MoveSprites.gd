extends Node2D

func _ready():
	yield(get_tree(), "idle_frame")
	for i in range(get_child_count()):
		var child = get_child(i)
		if child != null and child.name == "ShaderSprite":
			_move_child_to_port(child)
		for j in range(child.get_child_count()):
			var grandchild = child.get_child(j)
			if grandchild != null and grandchild.name == "ShaderSprite" or grandchild.name == "LavaShaderSprite":
				_move_child_to_port(grandchild)
			for h in range(grandchild.get_child_count()):
				var great_grandchild = grandchild.get_child(h)
				if great_grandchild != null and great_grandchild.name == "ShaderSprite":
					_move_child_to_port(great_grandchild)

func _move_child_to_port(child):
	var global_pos = child.global_position
	var size = child.global_scale
	var rot = child.global_rotation

	var viewport = Global.ShaderPort

	var current_parent = child.get_parent()
	if current_parent:
		current_parent.call_deferred("remove_child", child)
	viewport.call_deferred("add_child", child)

	yield(get_tree(), "idle_frame")
	child.global_position = global_pos
	child.global_scale = size
	child.global_rotation = rot
	if child is SS2D_Shape_Closed:
		child.z_index = 100
	else:
		child.z_index = -100
