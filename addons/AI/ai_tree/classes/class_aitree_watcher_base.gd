@abstract
class_name AIWatcherBase
extends Resource

var tree:GugaTree

@abstract func event_update( aitree:AITreeBase )

func _init() -> void:
	tree = Engine.get_main_loop()
