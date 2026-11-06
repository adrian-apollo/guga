class_name AIT_MovePawnToLocation2D extends AITaskBase

@export var location:Vector2 = Vector2.ZERO
@export var tolerance_radius:float = 0.0

func enter( aitree: AITreeBase ):
	aitree.aicontroller.move_pawn_to_destination( Vector3( location.x, location.y, 0), tolerance_radius )
	finish_task( aitree )
