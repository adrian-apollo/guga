class_name CIsValidActor extends AITCondition

@export var bb_key:StringName = &""

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	if is_instance_valid(
		aitree.blackboard.get(
			bb_key
		)
		):
		return true
	return false
