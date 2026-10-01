class_name CSenderTest extends ComponentBase

@export var receiver_path:NodePath

var receiver:Node

func event_begin():
	receiver = tree.get_node_from_nodepath(tree.current_level, receiver_path )
	#tree.safe_load("uid://dwfjiewivmenq", progress, finished )

func finished(res):
	print("finished: " + str( res ))
	
func progress(value:float):
	print("progress:" + str( value * 100) + "\n")

func event_tick():
	if receiver:
		tree.execute(receiver, "event_hit", [randf_range(0, -5)])
