class_name AIWActorProperty extends AIWatcherBase

@export var actor_property_name:StringName

var property

func event_update(  aitree:AITreeBase ):
	#property = tree.get_property_value_from_actor( actor, actor_property_name)
	pass
