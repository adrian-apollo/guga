class_name AITreeBase
extends Node

@export var watchers:Array[ AIWatcherBase ]
@export var initial_state:AIState

signal tree_completed

var blackboard:Dictionary[ StringName, Variant ]
var states:Array[ Node ]
var current_state:AIState
var state_evaluation:bool = true
var lock_in_task:AITaskBase

func _ready():
	if get_child_count() > 0:
		states = get_children()
		if initial_state:
			current_state = initial_state
		else:
			current_state = states[0]

func _physics_process(delta: float):
	blackboard.clear()
	state_evaluation = true
	update_watchers()
	
	if !evaluate_state_conditions():
		state_evaluation = false
	
	if state_evaluation:
		run_next_state_task( null )

	make_transition()	
	
func update_watchers():
	for w in watchers:
		w.event_update( self )

##	Check if all conditons are meet, if true then run tasks.
func evaluate_state_conditions() -> bool:
	for e in current_state.condition:
		if !e.evaulate( self, current_state ):
			return false
	return true

func run_next_state_task( previous:AITaskBase ):
	pass
	

func make_transition():
	pass
