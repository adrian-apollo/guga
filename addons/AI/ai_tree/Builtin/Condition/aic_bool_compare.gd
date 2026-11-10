class_name CBoolCompare extends AITCondition

@export var if_parameter_name:StringName = &"pawn_is_moving"
@export var _is:bool
@export var _not:bool

func evaulate( aitree:AITreeBase, _state:AIState ) -> bool:
	if !aitree.parameters.has( if_parameter_name ):
		return false

	var value:bool = aitree.parameters[ if_parameter_name ]
	
	if _not:
		if !value == _is:
			return true	

	if value == _is:
		return true
	
	return false