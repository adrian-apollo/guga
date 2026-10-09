@abstract
class_name AIWatcherBase
extends Node

@export var ticksource:TICKSOURCE
@export var tickrate:float = 1

enum TICKSOURCE {
	NONE,
	PROCESS,
	PHYSICS,
	CUSTOM
}

var tree:GugaTree
var actor:Node

func _init() -> void:
	tree = Engine.get_main_loop()

func _ready():
	
	set_process( false )
	set_physics_process( false )
	if tickrate > 0:
		_start_tick()
		
	if owner is AITreeBase:
		owner.add_watcher(self)

	call_deferred(&"event_start")

func event_start():
	actor = owner.owner

func event_update():
	pass

#region
func _start_tick():
	match ticksource:
		TICKSOURCE.NONE:
			return
		TICKSOURCE.PROCESS:
			tree.process_frame.connect( event_update )
		TICKSOURCE.PHYSICS:
			tree.physics_frame.connect( event_update )
		TICKSOURCE.CUSTOM:
			tree.connect_callable_to_timer(event_update, tickrate)

func _stop_tick():
	if tree.physics_frame.is_connected( event_update ):
		tree.physics_frame.disconnect( event_update )
		return
	if tree.process_frame.is_connected( event_update ):
		tree.process_frame.disconnect( event_update )
		return

	tree.disconnect_callable_from_timer( event_update, tickrate )

func _reset_tick( _ticksource:TICKSOURCE, _tickrate:int ):
	ticksource = _ticksource
	tickrate = _tickrate
	_stop_tick()
	_start_tick()

#endregion
