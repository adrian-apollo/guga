class_name CReceiverTest extends ComponentBase

@export var label_path:NodePath

var life:float = 30
var comment_label:Label = null

func event_begin():
	comment_label = tree.get_node_from_nodepath(owner, label_path)
	tree.send_global_notification("hit", life)

func event_hit(damage:float):
	comment_label.text = "hit aggg!!!!\nstill alive "
	life += damage
	if life < 0:
		life = 0
		tree.destroy_actor( owner )
	tree.send_global_notification("hit", roundf( life ))
