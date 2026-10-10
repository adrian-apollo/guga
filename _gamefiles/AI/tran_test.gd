class_name TGoToState extends AITransition

@export var nodepath:NodePath

func make_transition( _result:AIState.RESULT ):
	var state_ref:AIState = tree.get_node_from_nodepath( aitree, nodepath)
	if is_instance_valid( state_ref ):
		if state_ref is AIState:
			state_ref.call_deferred(&"start")
	return
