@abstract
class_name AIWatcherBase
extends Resource

@export var parameter_to_update:StringName

var tree:GugaTree

func _init() -> void:
	tree = Engine.get_main_loop()

func event_begin( _aitree:AITreeBase ):
	pass

func event_update( _aitree:AITreeBase ):
	pass

func _update_parameter( aitree:AITreeBase, parameter_name:StringName, value:Variant ):
	if aitree and !parameter_name.is_empty():
		aitree.parameters[ parameter_name] = value