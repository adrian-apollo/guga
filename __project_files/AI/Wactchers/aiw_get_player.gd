class_name AIW_GetPlayer extends AIWatcherBase

@export var player_index:int = 0

func event_update( aitree:AITreeBase ):
	aitree.blackboard.set(&"player", tree.get_player_by_index( player_index ) )
