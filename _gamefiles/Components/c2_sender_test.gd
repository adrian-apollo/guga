class_name CSenderTest extends ComponentBase

@export var receiver_path:NodePath

var receiver:Node

func event_begin():
	receiver = tree.get_node_from_nodepath(tree.current_level, receiver_path )

func event_tick():
	if receiver:
		tree.execute(receiver, &"event_hit", [randf_range(0, -5)])
