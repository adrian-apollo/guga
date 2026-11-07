class_name AIT_MovePawnToLocation extends AITaskBase

@export var parameter_name:StringName = &"destination"
@export var tolerance_radius:float = 0.0

func enter( aitree: AITreeBase ):
	if aitree.parameters.get( parameter_name):
		finish_task(aitree, false )
	
	aitree.aicontroller.move_pawn_to_destination(
			aitree.parameters[ parameter_name ]
	)
	
	finish_task( aitree )
