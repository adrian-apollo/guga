class_name CIsNullProperty extends AITCondition

@export var parameter_name:StringName

func evaulate( aitree:AITreeBase, _state:AIState ) -> bool:
	if !aitree.parameters.get( parameter_name ):
		return true
	return false
