class_name CAreaDetector extends ComponentBase

@export var monitored_area:NodePath

var area2d:Area2D

func event_begin():
	if monitored_area.is_empty():
		area2d = owner
	else:
		area2d = tree.get_node_from_nodepath(owner, monitored_area )
	
	area2d.area_entered.connect( destroy )

func destroy( area:Area2D ):
	tree.execute( area.owner, &"decrease_health", [10])
	owner.queue_free()
