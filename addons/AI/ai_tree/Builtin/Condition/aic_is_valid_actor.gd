class_name CIsValidActor extends AITCondition

@export var parameter_name:StringName = &"pawn"

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	if !aitree.parameters.get( parameter_name):
		return false

	if is_instance_valid( aitree.parameters[ parameter_name ] ):
		return true

	return false
