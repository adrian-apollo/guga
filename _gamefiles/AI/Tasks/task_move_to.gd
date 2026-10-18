class_name AIT_MoveToActor extends AITaskBase

@export var watcher_property:StringName

var node:Node2D

func enter():
	if watcher_property.is_empty():
		finish()
	
	node = aitree.get_watcher_property( watcher_property )
	if is_instance_valid( node ):
		finish()
	
	(actor as Node2D ).look_at( node.global_position )
	(actor as Node2D ).position += 1 * (actor as Node2D ).global_position.direction_to( node.global_position )
	
	finish()
