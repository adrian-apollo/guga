class_name TGoToState extends AITransition

@export var nodepath:NodePath

func make_transition( _result:RESULT ):
	print( nodepath )
	var next_state:AIState = tree.get_node_from_nodepath( aitree, nodepath)
	if is_instance_valid( next_state ):
		if next_state is AIState:
			if tick_source == TICKSOURCE.PHYSICS_START:
				next_state.get_tree().physics_frame.connect( next_state.start, 4 )
				return
			if tick_source == TICKSOURCE.PROCESS_START:
				next_state.get_tree().process_frame.connect( next_state.start, 4 )
				return
	return
