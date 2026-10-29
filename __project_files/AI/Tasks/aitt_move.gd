class_name AITT_Move extends AITaskBase

func update( aitree: AITreeBase ):
	var alien:CharacterBody2D = aitree.owner
	#print( aitree.blackboard.get(&"player_position"))
	alien.velocity = Vector2(0,400)
	alien.move_and_slide()
	print( Engine.get_physics_frames() )
	exit(aitree )
