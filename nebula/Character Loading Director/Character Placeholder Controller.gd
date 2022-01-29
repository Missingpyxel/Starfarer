extends KinematicBody2D

func _process(delta):
	
	var move_vector = Vector2(
		int(Input.is_action_pressed("move_right"))
	  - int(Input.is_action_pressed("move_left")), 
		int(Input.is_action_pressed("move_down")) 
	  - int(Input.is_action_pressed("move_up")))
	
	move_and_slide_with_snap(move_vector.normalized() * 40, Vector2.ZERO)

