class_name AITT_MoveToRandomLocation extends AITaskBase

@export var distance:int

func update( aitree: AITreeBase ):
	var pawn:Node2D = aitree.pawn
	aitree.parameters[ &"poi" ] = Vector2( pawn.global_position.x + randf_range(-distance, distance ), pawn.global_position.y + randf_range(-distance, distance ))
	#pawn.global_position = Vector2( pawn.global_position.x + randf_range(-distance, distance ), pawn.global_position.y + randf_range(-distance, distance ))
	print( aitree.parameters[ &"poi" ] )
	exit(aitree )
