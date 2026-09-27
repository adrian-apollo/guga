extends Resource
class_name ComponentsHolder

@export var components:Array[ComponentBase2]
var tree:GugaTree

func _init():
	tree = Engine.get_main_loop()
	
func _setup_local_to_scene():
	tree.s_component_unlisted.connect(remove_component)
	tree.s_actor_unlisted.connect(owner_destroyed)
	
func remove_component(actor:Node, component:ComponentBase2):
	if actor!=get_local_scene():
		return

	component._destructor()
	components.erase(component)

func owner_destroyed(actor:Node):
	if !is_instance_valid( actor ):
		return
	if actor!=get_local_scene():
		return
	for component in components:
		remove_component( actor, component )
	
	tree.s_component_unlisted.disconnect(remove_component)
	tree.s_actor_unlisted.disconnect(owner_destroyed)
