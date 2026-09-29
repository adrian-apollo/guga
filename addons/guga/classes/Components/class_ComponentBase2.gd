class_name ComponentBase2 extends Resource

#region configuration
@export_group("Component")
@export var active:bool = true:
	set(value):
		active = value
	get:
		return active
@export_group("Tick")
@export var enabled:bool = true
@export var custom:bool = false
@export_range(1, 60, 1, "or_greater") var tick_rate:int = 1

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
	call_deferred("event_begin")

func _start_tick():
	if enabled:
		if custom:
			tree.connect_callable_to_timer(event_tick, tick_rate)
		else:
			tree.physics_frame.connect(event_tick)
	
func _stop_tick():
	if tree.physics_frame.is_connected( event_tick ):
		tree.physics_frame.disconnect(event_tick)
		return

	tree.disconnect_callable_from_timer( event_tick, tick_rate )

func _reset_tick(_enabled:bool, _custom:bool, _tickrate:int):
	enabled = _enabled
	custom = _custom
	tick_rate = _tickrate
	_stop_tick()
	_start_tick()
	
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
