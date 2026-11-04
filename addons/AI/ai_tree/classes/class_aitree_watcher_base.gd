@abstract
class_name AIWatcherBase
extends Resource

@export var parameter_to_update:StringName

var tree:GugaTree

func _init() -> void:
	tree = Engine.get_main_loop()

@abstract func event_update( aitree:AITreeBase )

func _update_parameter( aitree:AITreeBase, parameter_name:StringName, value:Variant ):
	if aitree and !parameter_name.is_empty():
		aitree.parameters[ parameter_name] = value
	
