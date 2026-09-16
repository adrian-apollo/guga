class_name GugaTree extends SceneTree

#region	signals
#	message bus
signal s_message(receiver: Object, callable:String, data:Array)

#	level managing 
signal s_level_changed( Level )
signal s_level_destroyed( Level )
signal s_level_loaded( Level )

#	timers
signal s_timer_created
signal s_timer_destroyed

#endregion

#region variables
#  level managing
var current_level:Level:
	set(level):
		current_level = level
	get:
		return current_level

var cached_levels:Array[Node]:
	get:
		return cached_levels
 
#  timers
var available_timers: Dictionary[float, Timer] = {}

#endregion

#region	initialization
#  tree init
func _initialize():
	print("GugaTree->Starting game")
	
#endregion

#region level managing
func load_level( level:String )->Level:
	var newlevel:Level = ( ResourceLoader.load(level).instantiate() as Level )
	s_level_loaded.emit( newlevel )
	return newlevel

func change_to_level( levelref:Level, destroy_previous:bool ):
	if !levelref:
		return
	if current_level:
		if destroy_previous:
			current_level.queue_free()
		else:
			cached_levels.push_back( current_level )

	get_root().add_child( levelref )
	current_level = levelref
	s_level_changed.emit( levelref )

func get_current_level() -> Node:
	return

func delete_level(levelref:Node):
	s_level_destroyed.emit( levelref)

#endregion

#region message system
func send_message(receiver: Object, callable:String, data:Array)->bool:
	if !receiver:
		return false
	if callable.is_empty():
		return false

	s_message.emit(receiver, callable, data)
	return true

#endregion

#region timers
func connect_callable_to_timer(callableref:Callable, tickrate:int):
	#  check first if the timer with that frequency exists 
	#  if not create a new one
	if tickrate < 1:
		print(" GugaTree >> Invalid tick rate value: < 1 ")
		return
	
	if !available_timers.has(tickrate):
		_new_timer( tickrate )
	
	( available_timers.get(tickrate) as Timer ).connect("timeout", callableref)

#	pending test
func disconnect_callable_from_timer( callableref:Callable, tickrate:int ):
	var timerref:Timer = available_timers.find_key( tickrate )
	if !is_instance_valid( timerref ):
		print("GUGATree >> timer disconnection failed, invalid timer reference")
		return
	
	if !timerref.timeout.is_connected( callableref ):
		print("GUGATree >> timer disconnection failed, unexistent conncetion")
		return
	
	timerref.timeout.disconnect(callableref)
	if timerref.timeout.get_connections().size() == 0:
		timerref.queue_free()
		available_timers.erase( tickrate )

func _new_timer(hertz:int):
	var newtimerref:Timer = Timer.new()
	get_root().add_child( newtimerref )
	newtimerref.start( 1/float( hertz ) )
	newtimerref.set_autostart( true )
	newtimerref.name = "Timer_" + str( int( hertz ) )
	available_timers.set( hertz, newtimerref )

#endregion

#region test tree

func _test():
	print("GUGATree alive")

#endregion
