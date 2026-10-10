class_name TTryResult extends AITransition

@export_group("States")
@export var on_success_go_to:NodePath
@export var on_fail_go_to:NodePath

func make_transition( _result:AIState.RESULT ):
	var success:AIState = tree.get_node_from_nodepath( aitree, on_success_go_to)
	var fail:AIState = tree.get_node_from_nodepath( aitree, on_fail_go_to)
	
	var selection:AIState
	#	SUCCESS
	if !_result:
		selection = success
	if _result:
		selection = fail
	
	if is_instance_valid( selection ):
		if tick_source == TICKSOURCE.PHYSICS_START:
			selection.get_tree().physics_frame.connect( selection.start, 4 )
			return
		if tick_source == TICKSOURCE.PROCESS_START:
			selection.get_tree().process_frame.connect( selection.start, 4 )
			return
	
	return
