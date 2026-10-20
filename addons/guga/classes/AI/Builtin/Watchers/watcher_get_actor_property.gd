class_name AIW_ActorProperty extends AIWatcherBase

@export var actor_property_name:StringName = &"global_position"

func event_update(  aitree:AITreeBase ):
	aitree.blackboard.set( actor_property_name, aitree.owner.get( actor_property_name ))
