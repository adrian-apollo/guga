@abstract
class_name PseudoNode
extends Resource

@export_group("Tick")
@export var physics:bool
@export var process:bool
@export var custom:bool
@export_range(0, 60,0.001, "or_greater") var tick_rate:float = 1

#endregion

var owner:Node
var tree:GugaTree
var _level:Level

func _init():
	tree = Engine.get_main_loop()

func _start():
	call_deferred( &"event_begin" )
	call_deferred( &"_start_tick" )
	
	if !tree:
		tree = Engine.get_main_loop()
	
	if owner is Level:
		_level = owner
	else:
		_level = tree.find_owning_level( owner )

	_level.destroying_level.connect( _destructor )
	
	if owner:
		if !owner.tree_entered.is_connected( _start_tick ):
			owner.tree_entered.connect( _start_tick )
		if !owner.tree_exited.is_connected( _stop_tick ):
			owner.tree_exited.connect( _stop_tick )

#region virtual methods
##	called when the component is ready
func event_begin():
	pass

##	
func event_physics_tick( delta:float ):
	pass

func event_process_tick( delta:float ):
	pass

func event_custom_tick():
	pass

func event_destroy():
	pass

#endregion

#region tick configuration

func _start_tick():
	if !_level:
		return

	_enable_physics_update( physics )
	_enable_process_update( process )
	_enable_custom_update( custom )

func _stop_tick():
	if !_level:
		return
	
	_enable_physics_update( false )
	_enable_process_update( false )
	_enable_custom_update( false )

func _reset_tick():
	_stop_tick()
	_start_tick()

func _enable_physics_update( value:bool):
	if value:
		_level.physics_update.connect( event_physics_tick )
	elif _level.physics_update.is_connected( event_physics_tick ):
		_level.physics_update.disconnect( event_physics_tick )

func _enable_process_update( value:bool):
	if value:
		_level.process_update.connect( event_process_tick )
	elif _level.process_update.is_connected( event_process_tick ):
		_level.process_update.disconnect( event_process_tick )

func _enable_custom_update( value:bool):
	if value:
		tree.connect_callable_to_timer( _level, event_custom_tick, tick_rate )
	else:
		tree.disconnect_callable_from_timer( event_custom_tick, tick_rate )

#endregion

#region the end
func _destructor():
	_stop_tick()
	event_destroy()
	owner.tree_exiting.disconnect( _stop_tick )
	owner.tree_entered.disconnect( _start_tick )
#endregion
