class_name AITreeBase extends Node

@export var watchers:Array[ AIWatcherBase ]
@export var initial_state:AIState

enum STATE_RESULT {
	SUCCESS,
	FAIL
}

signal tree_completed

#	all particular data is stored on the AITree, AI elements are shared resources
var blackboard:Dictionary[ StringName, Variant ]
var states:Array[ Node ]

#	current state data
var current_state:AIState
var state_result:STATE_RESULT = STATE_RESULT.SUCCESS
var evaluation:bool = true

var running_task:AITaskBase
var next_task:AITaskBase

func _ready():
	if get_child_count() > 0:
		states = get_children()
		if initial_state:
			current_state = initial_state
		else:
			current_state = states[0]

func _physics_process( delta: float ):
	#	cleaning and reseting
	blackboard.clear()
	evaluation = true
	
	if state_result == STATE_RESULT.FAIL:
		transition()
		return
	
	update_watchers()
	
	evaluation = evaluate_state_conditions()
	
	if evaluation:
		run_tasks()
		return
	else:
		transition()
		return

##	Update watchers every tick passing a reference to the AITree
func update_watchers():
	for w in watchers:
		w.event_update( self )

##	Run all conditions, if all return true then run tasks.
func evaluate_state_conditions() -> bool:
	if !current_state:
		return true
	for e in current_state.condition:
		if !e.evaulate( self, current_state ):
			state_result = STATE_RESULT.FAIL
			return false
	return true

func run_tasks():
	if !current_state:
		return
	if current_state.tasks.size() == 0:
		transition()	#if the conditions are meet but theres no task the go to transiton
		return
	
	if !running_task:	#	run first task on the stack
		next_task = current_state.tasks[ 0 ]
	if next_task != running_task:	#	enter next task if diffrent from current task
		running_task = next_task
		running_task.enter_task( self )

	running_task.update_task( self )

func change_to_next_task( _result:STATE_RESULT ):
	state_result = _result
	#	get the the current task index
	var curr_task_index:int = current_state.tasks.find( running_task )
	#	if index equals state tasks size then make transition
	if curr_task_index + 1 == current_state.tasks.size():
		transition()
		return
	#	change to next task
	next_task = current_state.tasks[ curr_task_index +1 ]

##	A transition can be made if the evaluators return false,
##	or when all tasks are completed
func transition():
	if current_state.transitions.size() == 0:
		current_state = null
		return
	for t in current_state.transitions:
		t.make_transition( self )
		
		
