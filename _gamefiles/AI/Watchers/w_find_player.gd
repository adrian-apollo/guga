class_name AIWFindPlayer extends AIWatcherBase

var player:Node:
	get:
		return player

func event_begin():
	player = tree.get_player_by_index(0)
func event_update():
	player = tree.get_player_by_index(0)
