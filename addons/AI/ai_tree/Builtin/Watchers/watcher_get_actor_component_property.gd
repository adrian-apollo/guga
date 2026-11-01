class_name AIW_ActorComponentProperty extends AIWatcherBase

@export var actor_property_name:StringName = &"current_health"
@export var component_reference:ComponentBase = null

func event_update(  aitree:AITreeBase ):
	aitree.blackboard.set(
		actor_property_name,
		tree.get_component_property_from_actor(
			aitree.owner,
			component_reference,
			actor_property_name
			)
		)
