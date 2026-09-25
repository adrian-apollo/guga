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

#region	initialization
#  tree init
func _initialize():
	print("GugaTree->Starting game")
	
#endregion

#region level managing
var current_level:Level:
	set(level):
		current_level = level
	get:
		return current_level

var cached_levels:Array[Node]:
	get:
		return cached_levels
 
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
	return get( "current_level" )

func delete_level(levelref:Node):
	s_level_destroyed.emit( levelref)

#endregion

#region message system
func send_message(receiver: Object, callable:String, data:Array)->bool:
	if !is_instance_valid( receiver ):
		return false
	if callable.is_empty():
		return false

	s_message.emit(receiver, callable, data)
	return true

#endregion

#region timers
var available_timers: Dictionary[int, Timer] = {}
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
	var timerref:Timer = available_timers.get( tickrate )
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

#region actors & component system

var listed_actors:Dictionary[Node,Array]
var components:Array[ComponentBase]

func list_actor(actor:Node):
	if !is_instance_valid(actor):
		return
	listed_actors[actor] = []
	
func add_component_to_actor_key(actor:Node, component:ComponentBase):
	if !is_instance_valid(actor):
		return
	if !is_instance_valid(component):
		return
	listed_actors[actor].append(component)

func unlist_actor(actor:Node):
	if !listed_actors.has(actor):
		return
	listed_actors.get(actor).clear()
	listed_actors.erase(actor)

#	for cleaning purposes
func validate_all_keys():
	for key in listed_actors:
		if !is_instance_valid(key):
			unlist_actor(key)
	
#	components intercommunication section
var messages_received:Dictionary[Node,Variant]

func receive_message(actor:Node, message:Variant):
	#	add the message
	messages_received[actor] = message
	#	clean all messages on next tick start
	call_deferred(clean_messages())
	
func clean_messages():
	messages_received.clear()
#endregion

#region test tree

func _test():
	print("GUGATree alive")

#endregion
