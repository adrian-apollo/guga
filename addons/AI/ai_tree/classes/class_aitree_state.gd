class_name AIState extends Node

#region exports
##	A place to store data relevant to the state to share between conditions and tasks
@export var parameters:Dictionary[StringName, Variant]

##	This is behavior between a state and its child states.
##	Try enter = Will enter the phater state ignoring its children, default option for leafs states.
##	Select children in order = will run every state in the order they appear,used for chained behaviors.
##	Select childer in random order = will enter a random child state everytime, useful for random behavior.
@export var enter_behavior:ENTER_BEHAVIOR = ENTER_BEHAVIOR.TRY_ENTER_STATE

@export_category("Conditions")
@export var certified:COMPLETED = COMPLETED.ALL
##	An array of conditons, everyone must be true to run tasks, will fail if at least one is false.
@export var conditions:Array[ AITCondition ]

@export_category("Tasks")
@export var amount_to_complete:COMPLETED = COMPLETED.ALL
##	An array of task to complete. If a task fails to complete the state will not be completed thus failed.
@export var tasks:Array[ AITaskBase ]

##	Transitions selectable depending of the state result, SUCCESS or FAIL.
##	At least one should be added to give continuity to the execution of states.
@export_category("Transitions")
@export var transitions:Array [ AITransition ]
#endregion

#region enums

enum ENTER_BEHAVIOR{
	TRY_ENTER_STATE,
	SELECT_CHILDREN_IN_ORDER,
	SELECT_RANDOM_CHILD
}

enum COMPLETED{
	NONE,
	ONE,
	TWO,
	TREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGTH,
	NINE,
	THEEN,
	ANY,
	ALL
}

enum STATE_STAGES{
	ENTER,
	TICK,
	TRANSITION
}

enum STATE_RESULT{
	SUCCESS,
	FAILED
}
#endregion

var _active_task:AITaskBase
var _completed_tasks:int = 0
var aitree:AITreeBase
var _state_stage:STATE_STAGES = STATE_STAGES.ENTER
var _state_result:STATE_RESULT

func _init():
	set( &"process_mode", ProcessMode.PROCESS_MODE_DISABLED )

#region MAIN
func update_state( _aitree:AITreeBase ):
	if _state_stage == STATE_STAGES.ENTER:
		enter_stage( _aitree )
	
	if _state_stage == STATE_STAGES.TICK:
			tick_stage()

	if _state_stage == STATE_STAGES.TRANSITION:
		if _enter_behavior():
			return
		transition_stage()

func enter_stage( _aitree:AITreeBase ):
	aitree = _aitree
	
	if !_evaluate_completed_conditions():
		_state_stage = STATE_STAGES.TRANSITION

	if tasks.size() > 0:
		_active_task = tasks[0]
		_state_stage = STATE_STAGES.TICK
	else:
		_state_stage = STATE_STAGES.TRANSITION

func tick_stage():
	if !is_instance_valid( _active_task):
		_state_stage = STATE_STAGES.TRANSITION

	if !_active_task.b_entered:
		_active_task.b_entered = true
		_active_task.enter( aitree )

	if _state_stage != STATE_STAGES.TICK:
		return

	if _evaluate_completed_tasks():
		_state_stage = STATE_STAGES.TRANSITION
		return
	
	_active_task.tick( aitree )

func transition_stage():
	_evaluate_transitions()

#endregion

#region private

func _evaluate_completed_conditions() -> bool:
	if transitions.size() == 0:
		return true

	var correct:int = 0
	for c in conditions:
		if c.evaulate( aitree, self ):
			correct += 1
	
	match certified:
		COMPLETED.ALL:
			if correct == conditions.size():
				return true
		COMPLETED.ANY:
			if correct > 0:
				return true
		COMPLETED.NONE:
			if correct == 0:
				return true
		COMPLETED.ONE:
			if correct == 1:
				return true
		COMPLETED.TWO:
			if correct == 2:
				return true
		COMPLETED.TREE:
			if correct == 3:
				return true
		COMPLETED.FOUR:
			if correct == 4:
				return true
		COMPLETED.FIVE:
			if correct == 5:
				return true
		COMPLETED.SIX:
			if correct == 6:
				return true
		COMPLETED.SEVEN:
			if correct == 7:
				return true
		COMPLETED.EIGTH:
			if correct == 8:
				return true
		COMPLETED.NINE:
			if correct == 9:
				return true
		COMPLETED.THEEN:
			if correct == 10:
				return true

	return false

func _evaluate_completed_tasks() -> bool:
	if amount_to_complete > tasks.size():
		amount_to_complete = tasks.size()

	match amount_to_complete:
		COMPLETED.ALL:
			if _completed_tasks == tasks.size():
				return true
		COMPLETED.ANY:
			if _completed_tasks > 0:
				return true
		COMPLETED.NONE:
			if _completed_tasks == 0:
				return true
		COMPLETED.ONE:
			if _completed_tasks == 1:
				return true
		COMPLETED.TWO:
			if _completed_tasks == 2:
				return true
		COMPLETED.TREE:
			if _completed_tasks == 3:
				return true
		COMPLETED.FOUR:
			if _completed_tasks == 4:
				return true
		COMPLETED.FIVE:
			if _completed_tasks == 5:
				return true
		COMPLETED.SIX:
			if _completed_tasks == 6:
				return true
		COMPLETED.SEVEN:
			if _completed_tasks == 7:
				return true
		COMPLETED.EIGTH:
			if _completed_tasks == 8:
				return true
		COMPLETED.NINE:
			if _completed_tasks == 9:
				return true
		COMPLETED.THEEN:
			if _completed_tasks == 10:
				return true

	return false

func _evaluate_transitions():
	for t in transitions:
		if t.make_transition( aitree ):
			break
			return
	
	if transitions.size() == 0:
		aitree._changet_to_state( aitree.initial_state )

func _enter_behavior() -> bool:
	if enter_behavior == ENTER_BEHAVIOR.TRY_ENTER_STATE:
		return false
	if enter_behavior == ENTER_BEHAVIOR.SELECT_CHILDREN_IN_ORDER:
		if get_child_count() > 0:
			var last:AIState = aitree.active_hierarchy.back()
			if !get_children().has( last ) and last == self:
				aitree._changet_to_state( get_child( 0 ) )
			return true
	if enter_behavior == ENTER_BEHAVIOR.SELECT_RANDOM_CHILD:
		if get_child_count() > 0:
			aitree._changet_to_state( get_children().pick_random() )
			return true
	return true

#endregion
