class_name AITreeBase extends Node

@export var initial_state:AIState

@export_category("Watchers")
@export var watchers:Array[ AIWatcherBase ]

@export_category("Constant parameters")
@export var const_parameters:Dictionary[ StringName, Variant ]

var pawn:Node
var aicontroller:AIController

var _tree:GugaTree

var current_state:AIState
var active_hierarchy:Array[ Node ]
var parameters:Dictionary[StringName, Variant]

func _init():
	set_process( false )
	_tree = Engine.get_main_loop()
	
func _ready():
	
	if get_child_count() == 0:
		set( &"process_mode", ProcessMode.PROCESS_MODE_DISABLED )

	if initial_state:
		_changet_to_state( initial_state )
	else:
		initial_state = get_child( 0 )
		_changet_to_state( initial_state )

func _physics_process( delta: float ):
	parameters[&"pawn"] = pawn
	parameters[&"aicontroller"] = aicontroller
	parameters[&"pawn_is_moving"] = aicontroller.pawn_is_moving
	parameters[&"destination"] = aicontroller.destination
	
	update_watchers()
	
	var tmp:Array[Node] = active_hierarchy

	for s in tmp:
		if tmp != active_hierarchy:
			break
			return
		if !s:
			break
			return

		current_state = s
		current_state.update_state( self )

func update_watchers():
	for w in watchers:
		if is_instance_valid( w ):
			w.event_update( self )

func _changet_to_state( new_state:AIState ):
	active_hierarchy = _tree.get_inbeetwen_nodes( self, new_state, false, true )
	_clear_parameters()
	for s in active_hierarchy:
		s.parameters.clear()
		s._state_result = AIState.STATE_RESULT.SUCCESS
		s._active_task = null
		s._completed_tasks = 0
		s._state_stage = AIState.STATE_STAGES.ENTER
		s._state_result = AIState.STATE_RESULT.SUCCESS

func _restart_parameters():
	parameters.merge( const_parameters )
	parameters[&"pawn"] = pawn
	parameters[&"aicontroller"] = aicontroller
	parameters[&"pawn_is_moving"] = aicontroller.pawn_is_moving
	parameters[&"destination"] = aicontroller.destination

func _clear_parameters():
	parameters.clear()
