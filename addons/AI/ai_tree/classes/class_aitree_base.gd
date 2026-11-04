class_name AITreeBase extends Node

@export var watchers:Array[ AIWatcherBase ]
@export var parameters:Dictionary[StringName, Variant]
@export var initial_state:AIState

var pawn:Node
var aicontroller:AIController

var _tree:GugaTree

var current_state:AIState

func _init():
	set_process( false )
	_tree = Engine.get_main_loop()
	
func _ready():
	
	if get_child_count() == 0:
		set( &"process_mode", ProcessMode.PROCESS_MODE_DISABLED )
		
	if initial_state:
		current_state = initial_state
	else:
		current_state = get_child( 0 )

func _physics_process( delta: float ):
	update_watchers()
	current_state.update_state( self )

func update_watchers():
	for w in watchers:
		if is_instance_valid( w ):
			w.event_update( self )

func _changet_to_state( new_state:AIState ):
	current_state._active_task = null
	current_state._completed_tasks = 0
	current_state._state_stage = AIState.STATE_STAGES.ENTER
	current_state._state_result = AIState.STATE_RESULT.SUCCESS
	current_state = new_state
