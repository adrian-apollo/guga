class_name AITreeBase extends Node

@export var watchers:Array[ AIWatcherBase ]
@export var initial_state:AIState

enum RESULT{
	SUCCEDED,
	FAILED
}

enum PHASE {
	EVALUATING,
	EXECUTING,
	TRANSITIONING
}

##	temporal data is stored on the AITree, state elements are shared resources
var blackboard:Dictionary[ StringName, Variant ]

##	The current updated state, this will change from hiererchaly
var current_state:AIState
##	The current task reference running
var current_task:AITaskBase
##	The pass at wich the state is currently
var phase:PHASE = PHASE.EVALUATING
##	The final evaluation of the state, from evaluators and tasks
var result:RESULT = RESULT.SUCCEDED

func _ready():
	if get_child_count() > 0:
		if initial_state:
			current_state = initial_state
		else:
			current_state = get_child( 0 )

func _physics_process( delta: float ):
	print( Engine.get_physics_frames() )
	if !current_state:
		return

	update_watchers()
	
	match phase:
		PHASE.EVALUATING:
			evaluate_conditions()
		PHASE.EXECUTING:
			run_tasks()
			if !current_state.BEHAVIOR.TRY_ENTER_STATE and result == RESULT.SUCCEDED:
				hierercharly_switch()
		PHASE.TRANSITIONING:
			transition()
		
#region

##	Update watchers every tick passing a reference to the AITree
func update_watchers():
	if !current_state:
		return
	for w in watchers:
		if !w:
			return
		w.event_update( self )

func change_to_state( newstate:AIState, _result:RESULT = RESULT.SUCCEDED, _phase:PHASE = PHASE.EVALUATING ):
	current_task = null
	phase = _phase
	result = _result

	if result == RESULT.FAILED:
		phase = PHASE.TRANSITIONING
	
	current_state = newstate

##	Run all conditions, if all return true then go to run tasks.
func evaluate_conditions():
	for e in current_state.condition:
		if !e.evaulate( self, current_state ):
			phase = PHASE.TRANSITIONING
			return false
	phase = PHASE.EXECUTING

func run_tasks():
	if result == RESULT.FAILED:
		phase = PHASE.TRANSITIONING
		return

	if current_state.tasks.size() == 0:
		phase = PHASE.TRANSITIONING
		return
	
	#	run first task from the stack
	if !current_task:
		current_task = current_state.tasks[ 0 ]
	
	#	enter if not
	if !current_task.b_entered:
		current_task.b_entered = true
		current_task.enter( self )
	
	#	change to next task
	if current_task.b_completed:
		var ctindex:int = current_state.tasks.find( current_task )
		current_task.b_completed = false
		current_task.b_entered = false
		#	change to transition phase if all task are completed
		if current_state.tasks.size() == ctindex+1:
			phase = PHASE.TRANSITIONING
			return
		current_task = current_state.tasks[ ctindex + 1 ]

	current_task.update( self )

##	A transition can be made if the evaluators return false,
##	or when all tasks are completed
func transition():
	if current_state.transitions.size() == 0:
		current_state = null
		return
	for t in current_state.transitions:
		if t:
			t.make_transition( self )

func hierercharly_switch():
	if current_state.b_is_leaf_state and current_state.get_parent().get_script() != AITreeBase:
		var parent:AIState = current_state.get_parent()
		match parent.enter_behavior:
			AIState.BEHAVIOR.SELECT_CHILDREN_IN_ORDER:
				var csindex:int = parent.children.find( current_state )
				if csindex == parent.children.size()-1:
					change_to_state( parent, RESULT.SUCCEDED, PHASE.TRANSITIONING )
					return
				change_to_state( parent.get_child( csindex + 1 ) )
				return
			AIState.BEHAVIOR.SELECT_RANDOM_CHILD:
				if current_state.transitions.size() > 0:
					phase = PHASE.TRANSITIONING
					return
				change_to_state( parent.children.pick_random() )
				return
		return

	match current_state.enter_behavior:
		AIState.BEHAVIOR.TRY_ENTER_STATE:
			return
		AIState.BEHAVIOR.SELECT_CHILDREN_IN_ORDER:
			change_to_state( current_state.get_child( 0 ))
			return
		AIState.BEHAVIOR.SELECT_RANDOM_CHILD:
			change_to_state( current_state.get_children().pick_random() )
			return

#endregion
