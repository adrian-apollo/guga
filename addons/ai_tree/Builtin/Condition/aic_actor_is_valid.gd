class_name CIsOfBuiltInClass extends AITCondition

@export var bb_key:StringName = &"actor"
@export var class_type:StringName = &"Node"

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	if !aitree.blackboard.get( bb_key ):
		return false
	if aitree.blackboard.get( bb_key ).is_class( class_type ):
			return true
	return false
