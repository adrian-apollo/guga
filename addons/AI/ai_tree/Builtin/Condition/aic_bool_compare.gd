class_name CBoolCompare extends AITCondition

@export var if_parameter_name:StringName = &"pawn_is_moving"
@export var _is:bool = true

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	if !aitree.parameters.has( if_parameter_name ):
		return false

	var value:bool = aitree.parameters[ if_parameter_name ]
	
	if value == _is:
		return true
	
	return false
