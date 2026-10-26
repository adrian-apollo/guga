class_name CIsNullProperty extends AITCondition

@export var bb_key:StringName

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	if !aitree.blackboard.get( bb_key ):
		return true
	return false
