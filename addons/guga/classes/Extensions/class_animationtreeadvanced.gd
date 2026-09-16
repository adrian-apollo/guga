class_name AnimationTreeAdvanced extends AnimationTree

func _changenodefromuid(
	parentnodename:String,
	parentnodeindex:int,
	newnodename:String,
	uid:String ):

	var newnode:AnimationNode = load(uid)
	tree_root.disconnect_node(parentnodename, parentnodeindex)
	tree_root.remove_node(newnodename)
	tree_root.add_node(newnodename, newnode)
	tree_root.connect_node(parentnodename, 0, newnodename)

func _changenodefromintstance(
	parentnodename:String,
	parentnodeindex:int,
	newnodename:String,
	newnode:AnimationNode ):
		
	tree_root.disconnect_node(parentnodename, parentnodeindex)
	tree_root.remove_node(newnodename)
	tree_root.add_node(newnodename, newnode)
	tree_root.connect_node(parentnodename, 0, newnodename)
