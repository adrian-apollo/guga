@tool
class_name Level extends Node

@export_group("Components")
@export var componentstack:ComponentStack

@export_group("GameMode")
@export var game_mode:GameMode

@export_group("Player start")
@export_tool_button("Add PlayerStart2D", "2D") var playerstart2d = add_playerstart2d
@export_tool_button("Add PlayerStart3D", "3D") var playerstart3d = add_playerstart3d

signal level_started
signal physics_update( float )
signal process_update( float )
signal destroying_level

var _tree:GugaTree
var ui:UIBase
var available_timers: Dictionary[float, Timer] = {}

func _init():
	if Engine.is_editor_hint():
		return
	
	_tree = Engine.get_main_loop() as GugaTree

func start():
	if game_mode:
		game_mode.init_game( self )
	level_started.emit()
	_tree.send_global_notification( &"LevelStarted", self )

func _physics_process(delta: float):
	physics_update.emit( delta )
	
func _process(delta: float):
	process_update.emit( delta )

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		destroying_level.emit()

#region player start
func add_playerstart2d():
	var ps = load("uid://c7iuw10w7ox4x").instantiate()
	add_child( ps )
	ps.owner = self
	ps.position = get_viewport().get_visible_rect().size / 2

func add_playerstart3d():
	var ps = load( "uid://2k1fwn8baejt" ).instantiate()
	add_child( ps )
	ps.owner = self

#endregion

#region	Managments of Actors inside the level

signal s_actor_listed( actor:Node )
signal s_actor_unlisted( actor:Node )
signal s_component_listed( actor:Node, component:ComponentBase )
signal s_component_unlisted( actor:Node, component:ComponentBase )

var actors:Dictionary[Node,Array]
var components:Array[ComponentBase]

func list_actor( actor:Node ):
	if !is_instance_valid(actor):
		return

	s_actor_listed.emit( actor )
	actors[actor] = []

func unlist_actor(actor:Node):
	if !is_instance_valid(actor):
		return
	if !actors.has(actor):
		return
	s_actor_unlisted.emit( actor )
	actors.erase(actor)
	actor.queue_free()

func list_component(actor:Node, component:ComponentBase):
	if !is_instance_valid(actor):
		return
	if !is_instance_valid(component):
		return
	if !actors.has(actor):
		list_actor(actor)
	if actors[actor].has(component):
		return

	s_component_listed.emit( actor, component )
	actors[actor].append(component)
	components.push_back( component )
	component.setup(actor)

func unlist_component(actor:Node, component:ComponentBase):
	if !is_instance_valid(actor):
		return
	if !is_instance_valid(component):
		return
	actors[actor].erase(component)
	components.erase( component )
	s_component_unlisted.emit(actor, component)

func add_component_to_actor( actor:Node, component:Script ) -> ComponentBase:
	var newc:ComponentBase = component.new().duplicate_deep( Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL )
	list_component( actor, newc )
	return newc

func get_component_property_from_actor( actor_reference:Node, component:ComponentBase, property_name:StringName ) -> Variant:
	if !actor_reference:
		return
	if property_name.is_empty():
		return
	if !actors.has( actor_reference ):
		return

	for c in actors[ actor_reference ]:
		if c.get_script() == component.get_script():
			return c.get( property_name )
			break
	return
#endregion