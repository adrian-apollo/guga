extends Resource
class_name ComponentsHolder

@export var components:Array[ComponentBase2]
var tree:GugaTree

func _init():
	tree = Engine.get_main_loop()
	tree.s_component_unlisted.connect(remove_component)


func remove_component(actor:Node, component:ComponentBase2):
	if actor!=get_local_scene():
		return

	component._destructor()
	components.erase(component)
