@abstract
class_name AITaskBase extends Resource

var b_entered:bool = false

func enter( _aitree: AITreeBase ):
	pass

func tick( _aitree: AITreeBase ):
	pass

func finish_task( aitree: AITreeBase, result:bool = true):
	b_entered = false
	if result:
		aitree.current_state._completed_tasks += 1
	else:
		aitree.current_state._state_result = AIState.STATE_RESULT.FAILED
	
	var next_task_index:int = aitree.current_state.tasks.find( self ) + 1
	if next_task_index == aitree.current_state.tasks.size() :
		aitree.current_state._state_stage = AIState.STATE_STAGES.TRANSITION
		aitree.current_state._active_task = null
		return
	
	aitree.current_state._active_task = aitree.current_state.tasks[ next_task_index ]
	
	#aitree.current_state._active_task.enter()
