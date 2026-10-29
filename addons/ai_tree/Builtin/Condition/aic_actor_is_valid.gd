class_name CIsOfBuiltInClass extends AITCondition

@export var blackboard_key:StringName = &"actor"
@export var class_type:StringName = &"Node"

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	if !aitree.blackboard.get( blackboard_key ):
		return false
	if aitree.blackboard.get( blackboard_key ).is_class( class_type ):
			return true
	return false
