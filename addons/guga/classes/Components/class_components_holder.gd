extends Resource
class_name ComponentsHolder

@export var components:Array[ComponentBase2]
var tree:GugaTree
var owner:Node

func _init():
	tree = Engine.get_main_loop()

func _setup_local_to_scene():
	owner = get_local_scene()
	if !owner.ready.is_connected(_setup):
		owner.ready.connect(_setup, 4)

func _setup():
	tree.s_component_listed.connect( _add_component)
	tree.s_component_unlisted.connect( _remove_component)
	tree.s_actor_unlisted.connect( _owner_destroyed)
	for c in components:
		tree.list_component( owner, c )

func _remove_component(actor:Node, component:ComponentBase2):
	if actor!=owner:
		return
	if !components.has(component):
		return
	component._destructor()
	components.erase(component)

func _add_component( actor:Node, component:ComponentBase2 ):
	if actor != owner:
		return
	if components.has(component):
		return
	
	components.push_back(component)

func _owner_destroyed(actor:Node):
	if !is_instance_valid( actor ):
		return
	if actor!=owner:
		return
	for component in components:
		_remove_component( actor, component )
	
	tree.s_actor_unlisted.disconnect( _owner_destroyed)
	tree.s_component_unlisted.disconnect( _remove_component)
	tree.s_component_listed.disconnect( _add_component)
