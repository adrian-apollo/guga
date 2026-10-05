class_name AIW_Test extends AIWatcherBase

var count:int = 0

func event_update():
	count += 1
	print(" watcher count: " + str( count))
