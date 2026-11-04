class_name AITT_FindRandomLocation extends AITaskBase

@export var distance:int
@export var parameter_name:StringName

func update( aitree: AITreeBase ):
	if parameter_name.is_empty() or distance == 0 or !aitree.pawn:
		exit(aitree, RESULT.FAILED )

	var pawn:= aitree.pawn
	aitree.parameters[ parameter_name ] = Vector2( pawn.global_position.x + randf_range(-distance, distance ), pawn.global_position.y + randf_range(-distance, distance ))
	#pawn.global_position = Vector2( pawn.global_position.x + randf_range(-distance, distance ), pawn.global_position.y + randf_range(-distance, distance ))
	print( aitree.parameters[ parameter_name ] )
	exit( aitree )
