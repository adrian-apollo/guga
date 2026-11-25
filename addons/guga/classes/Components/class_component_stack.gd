@tool
extends Resource
class_name ComponentStack

@export var components:Array[ComponentBase]
var _tree:GugaTree
var owner:Node

func _init():
	if !Engine.is_editor_hint():
		_tree = Engine.get_main_loop()
	set( &"resource_local_to_scene", true)

func _setup_local_to_scene():
	owner = get_local_scene()
	if !owner.ready.is_connected(_setup):
		owner.ready.connect(_setup, 4)

func _setup():
	if Engine.is_editor_hint():
		return
	_tree.s_actor_unlisted.connect( _owner_destroyed)
	for c in components:
		_tree.list_component( owner, c )

func _owner_destroyed(actor:Node):
	if !is_instance_valid( actor ):
		return
	if actor!=owner:
		return
	components.clear()
	_tree.s_actor_unlisted.disconnect( _owner_destroyed)
