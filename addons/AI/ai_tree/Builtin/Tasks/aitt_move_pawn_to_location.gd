class_name AITMovePawnToLocation extends AITaskBase

@export var parameter_name:StringName
@export var tolerance_radius:float = 0.0

func enter( aitree: AITreeBase ):
	if !aitree.parameters.get( parameter_name):
		finish_task(aitree, false )
		return
	
	var destination:Vector3
	if aitree.parameters[ parameter_name ] is Vector2:
		destination = Vector3(
			aitree.parameters[ parameter_name ].x,
			aitree.parameters[ parameter_name ].y,
			0)
	else:
		destination = aitree.parameters[ parameter_name ]

	aitree.aicontroller.move_pawn_to_destination(
		destination
	)

	finish_task( aitree )
