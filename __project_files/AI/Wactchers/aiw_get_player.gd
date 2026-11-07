class_name AIW_GetPlayer extends AIWatcherBase

@export var player_index:int = 0

func event_update( aitree:AITreeBase ):
	if !tree.current_level.game_mode.controllers[player_index].pawn:
		return

	aitree.parameters[&"player"] = tree.current_level.game_mode.controllers[player_index].pawn
