class_name GugaTree extends SceneTree

#region	signals
#	message bus
signal s_message(receiver: Object, callable:String, data:Array)

#endregion

#region	initialization
#  tree init
func _initialize():
	_initialize_log_file()
	new_log_message(self, "GameStarted", LOG_MESSAGE_MODE.NORMAL)

#endregion

#region level managing
 
signal s_level_changed( Level )
signal s_level_destroyed( Level )
signal s_level_loaded( Level )

var current_level:Level:
	set(level):
		current_level = level
	get:
		return current_level

var cached_levels:Array[Node]:
	get:
		return cached_levels
 
func load_level( level:String )->Level:
	new_log_message(self, "Loading level from file: " + level, LOG_MESSAGE_MODE.NORMAL)
	var newlevel:Level = ResourceLoader.load(level).instantiate()
	
	if !is_instance_valid(newlevel):
		new_log_message(self, "FAIL LOADING LEVEL FROM FILE: " + level, LOG_MESSAGE_MODE.ERROR)
		return
	
	s_level_loaded.emit( newlevel )
	new_log_message(self, "SUCESS", LOG_MESSAGE_MODE.NORMAL)
	return newlevel

func change_to_level( levelref:Level, destroy_previous:bool ):
	if !levelref or !is_instance_valid( levelref ):
		new_log_message(self, "Fail changing to level(): " + str( levelref ), LOG_MESSAGE_MODE.ERROR)
		return

	if current_level and is_instance_valid(current_level):
		if destroy_previous:
			destroy_level(current_level)
		else:
			cached_levels.push_back( current_level )
			get_root().remove_child( current_level )

	get_root().add_child( levelref )
	current_level = levelref
	s_level_changed.emit( levelref )
	new_log_message(self, "Changed to level: " + str( levelref ), LOG_MESSAGE_MODE.NORMAL)

func destroy_level(levelref:Node):
	current_level.queue_free()
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
signal s_timer_created
signal s_timer_destroyed

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

#region component system

signal s_actor_listed(actor:Node)
signal s_actor_unlisted(actor:Node)
signal s_component_listed(actor:Node, component:ComponentBase2)
signal s_component_unlisted(actor:Node, component:ComponentBase2)

var listed_actors:Dictionary[Node,Array]
var components:Array[ComponentBase]

func list_actor(actor:Node):
	if !is_instance_valid(actor):
		return

	s_actor_listed.emit( actor )
	listed_actors[actor] = []

func unlist_actor(actor:Node):
	if !listed_actors.has(actor):
		return
	s_actor_unlisted.emit( actor )
	listed_actors.erase(actor)

func list_component(actor:Node, component:ComponentBase2):
	if !is_instance_valid(actor):
		return
	if !is_instance_valid(component):
		return
	if !listed_actors.has(actor):
		list_actor(actor)
	if listed_actors[actor].has(component):
		list_actor(actor)

	s_component_listed.emit( actor, component )
	listed_actors[actor].append(component)

func unlist_component(actor:Node, component:ComponentBase2):
	if !is_instance_valid(actor):
		return
	if !is_instance_valid(component):
		return
	listed_actors[actor].erase(component)
	s_component_unlisted.emit(actor, component)

#endregion

#region	components intercommunication section
#	for one to one communication between actors
#	when you know who is your receiver
#	only it will receive the message
#	if a component is expecting some data it can search for it here
#	ex: know about enemy health, location, status......

#	STEPS
#	seeker ask receiver for some data trough a callable( get_health()	)
#	receiver will send the data here
#	seeker checks if theres new data that matches the expected

#	many actor can communicate each tick
#	so we store that data on a dictionay for fast searching by key
var messages_received:Dictionary[Node,Variant]

func receive_message(actor:Node, message:Variant):
	#	add the message with actor as key
	messages_received[actor] = message
	#	clean all messages on next tick
	call_deferred(clean_messages())

func find_message(actor:Node) -> Variant:
	return messages_received.get(actor)

func clean_messages():
	messages_received.clear()

#endregion

#region	global nitification system
#	objective: communicate new events to many receivers
#	example: new day started, player death, objective reached, update UI data
#	just connect a callable to the signal, wait for to trigger, check the message and get the data

signal global_notification(message:String, data:Variant)

func connect_to_notification_signal(callable:Callable):
	global_notification.connect(callable)

func disconnect_from_notificaiton_signal(callable:Callable):
	global_notification.disconnect(callable)

func send_global_notification(message:String, data:Variant):
	global_notification.emit(message, data)

#endregion

#region	utilitary functions
func validate_signal_connections(signalref:Signal):
	if signalref.is_null():
		return
		
	for dict in signalref.get_connections():
		if !dict["callable"].is_valid():
			signalref.disconnect(dict["callable"])

func validate_dictionay_keys(dictionary:Dictionary):
	for key in dictionary:
		if !is_instance_valid(key):
			listed_actors.erase(key)
#endregion

#region	logging system
const LOG_ROUTE:String = "user://logs/"

enum LOG_MESSAGE_MODE{
	NORMAL,
	ERROR,
	WARNING
}

var log_file: FileAccess
var current_logfile_route: String = ""

var currenttime:String

func _initialize_log_file():
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("logs"):
		dir.make_dir("logs")
		
	var datetime:Dictionary = Time.get_datetime_dict_from_system()
	var filename:String = "%04d_%02d_%02d_%02d_%02d_%02d.log" % [
		  datetime.year, datetime.month, datetime.day,
		  datetime.hour, datetime.minute, datetime.second
		]
	current_logfile_route = LOG_ROUTE + filename
	
	log_file = FileAccess.open(current_logfile_route, FileAccess.WRITE)
	
	if !log_file:
		push_error("GUGATree failed to create a log file")
		return

	print("Log system ready")

func new_log_message(sender:Object, message:String, mode:LOG_MESSAGE_MODE):
	if !is_instance_valid(sender):
		return
	if message.is_empty():
		return
	
	currenttime = Time.get_time_string_from_system()
	var new_message:String = "%s [%s] %s  >>>  %s\n" % [LOG_MESSAGE_MODE.find_key(mode), currenttime, sender, message]
	
	match mode:
		LOG_MESSAGE_MODE.NORMAL:
			print(new_message.strip_edges())
		LOG_MESSAGE_MODE.ERROR:
			push_error(new_message.strip_edges())
		LOG_MESSAGE_MODE.WARNING:
			push_error(new_message.strip_edges())
	
	if log_file:
		log_file.store_string(new_message)
		log_file.flush()
#endregion

#region test tree

func _test():
	print("GUGATree alive")

#endregion

#region exit game
func _finalize():
	if log_file:
		log_file.close()
	
#endregion
