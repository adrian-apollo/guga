class_name AIW_ConsolePrint extends AIWatcherBase

@export var message:String = "Watching"

func event_update( aitree:AITreeBase ):
	print( message )
	print( aitree.current_state )
