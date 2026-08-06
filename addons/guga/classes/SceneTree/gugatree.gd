class_name GugaTree extends SceneTree

#region signals
#  message bus
signal signal_send_message(receiver: Object, data:Array)
#endregion

#region variables
#  level managing variables
var current_level:Node:
	get:
		return current_level

var cached_levels:Array[Node]:
	get:
		return cached_levels
#endregion

#region initialization
#  initialize the tree
func _initialize():
	print("GugaTree->Starting game")
#endregion

#region level managing
func preload_level( level:Node )->Node:
	return

func get_current_level() -> Node:
	return

func delete_level(level:Node):
	pass
#endregion

#region message system
func send_message(receiver: Object, data:Array)->bool:
	if !receiver:
		return false
		
	signal_send_message.emit(receiver, data)
	return true
	
#endregion
