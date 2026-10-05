class_name ComponentBase
extends Resource

#region configuration
@export_group("Component")
@export var active:bool = true:
	set(value):
		active = value
	get:
		return active

enum TICK_SOURCE {
	NONE,
	PROCESS,
	PHYSICS,
	CUSTOM
}
@export_group("Tick")
@export var tick_source:TICK_SOURCE
@export_range(0, 60,0.001, "or_greater") var tick_rate:float = 1

#endregion

var owner:Node
var tree:GugaTree

func _init():
	tree = Engine.get_main_loop()

func _setup(_owner:Node):
	owner = _owner
	owner.tree_exiting.connect(_stop_tick)
	owner.tree_entered.connect(_start_tick)
	_start_tick()
	call_deferred(&"event_begin")

#region tick

func _start_tick():
	match tick_source:
		TICK_SOURCE.NONE:
			return
		TICK_SOURCE.PROCESS:
			tree.process_frame.connect(event_tick)
		TICK_SOURCE.PHYSICS:
			tree.physics_frame.connect(event_tick)
		TICK_SOURCE.CUSTOM:
			tree.connect_callable_to_timer(event_tick, tick_rate)

func _stop_tick():
	if tree.physics_frame.is_connected( event_tick ):
		tree.physics_frame.disconnect( event_tick )
		return
	if tree.process_frame.is_connected( event_tick ):
		tree.process_frame.disconnect(event_tick)
		return

	tree.disconnect_callable_from_timer( event_tick, tick_rate )

func _reset_tick( _ticksource:TICK_SOURCE, _tickrate:int ):
	_stop_tick()
	tick_source = _ticksource
	tick_rate = _tickrate
	_start_tick()

#endregion

#region virtual methods
func event_begin():
	pass

func event_tick():
	pass
	
func event_destroy():
	pass

#endregion

#region the end
#func _notification(what):
	#if !is_instance_valid(self):
		#return
	#if what == NOTIFICATION_PREDELETE:
		#_destructor()

func _destructor():
	event_destroy()
	_stop_tick()
	owner.tree_exiting.disconnect(_stop_tick)
	owner.tree_entered.disconnect(_start_tick)
#endregion
