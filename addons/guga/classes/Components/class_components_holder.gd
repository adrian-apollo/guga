extends Resource
class_name ComponentsHolder

@export var components:Array[ComponentBase2]
var tree:GugaTree
var owner:Node

func _init():
	tree = Engine.get_main_loop()

func _setup_local_to_scene():
	owner = get_local_scene()
	owner.ready.connect(_setup, 4)
	
func _setup():
	tree.s_component_listed.connect(add_component)
	tree.s_component_unlisted.connect(remove_component)
	tree.s_actor_unlisted.connect(owner_destroyed)
	print(components)
	for c in components:
		tree.list_component( owner, c )

func remove_component(actor:Node, component:ComponentBase2):
	if actor!=owner:
		return
	if !components.has(component):
		return
	component._destructor()
	components.erase(component)

func add_component( actor:Node, component:ComponentBase2 ):
	if actor != owner:
		return
	if components.has(component):
		return
	
	components.push_back(component)

func owner_destroyed(actor:Node):
	if !is_instance_valid( actor ):
		return
	if actor!=owner:
		return
	for component in components:
		remove_component( actor, component )
	
	tree.s_component_unlisted.disconnect(remove_component)
	tree.s_actor_unlisted.disconnect(owner_destroyed)
