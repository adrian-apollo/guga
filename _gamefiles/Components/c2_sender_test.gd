class_name CSenderTest extends ComponentBase

@export var receiver_path:NodePath

var receiver:Node

func event_begin():
	receiver = tree.get_node_from_nodepath(tree.current_level, receiver_path )
<<<<<<< HEAD
=======
	#tree.safe_load("uid://dwfjiewivmenq", progress, finished )

func finished(res):
	print("finished: " + str( res ))
	
func progress(value:float):
	print("progress:" + str( value * 100) + "\n")
>>>>>>> 23825e5ad482122c7d0f55cf15ee89cdc0f45a25

func event_tick():
	if receiver:
		tree.execute(receiver, "event_hit", [randf_range(0, -5)])
