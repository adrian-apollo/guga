class_name GugaTree extends SceneTree

#region signals
#  message bus
signal s_send_message(receiver: Object, data:Array)

#  level managing 
signal s_level_changed
signal s_level_destroyed
signal s_level_loaded

#  timers
signal s_timer_created
signal s_timer_destroyed

#endregion

#region variables
#  level managing
var current_level:Node:
	get:
		return current_level

var cached_levels:Array[Node]:
	get:
		return cached_levels
 
#  timers
var available_timers: Dictionary[float, Timer] = {}

#endregion

#region initialization
#  initialize the tree
func _initialize():
	print("GugaTree->Starting game")
	call_deferred("connect_timer_to_callable", tick, 0.10)
#endregion

#region level managing
func preload_level( level:Node )->Node:
	return

func get_current_level() -> Node:
	return

func delete_level(level:Node):
	pass
#endregion

#region message system
func send_message(receiver: Object, data:Array)->bool:
	if !receiver:
		return false
		
	s_send_message.emit(receiver, data)
	return true
	
#endregion

#region timers
func connect_timer_to_callable(callableref:Callable, tickrate:float):
	#  check first if the timer with that frequency exists 
	#  if not create a new one
	if !available_timers.has(tickrate):
		new_timer( tickrate )
	
	( available_timers.get(tickrate) as Timer ).connect("timeout", callableref)

func new_timer(hertz:float):  
	var newtimerref:Timer = Timer.new()
	get_root().add_child( newtimerref )
	newtimerref.start( hertz )
	newtimerref.set_autostart( true )
	newtimerref.name = "Timer_" + str( int( hertz*100 ) )
	
	available_timers.set( hertz, newtimerref )

func destroy_timer(timerref: Timer):
	timerref.queue_free()

#endregion

func tick():
	print(" ticking ")
