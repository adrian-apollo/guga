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

var _tree:GugaTree
var _ui:UIBase

func _init():
	if Engine.is_editor_hint():
		return
	
	_tree = Engine.get_main_loop() as GugaTree

func _start():
	if game_mode:
		game_mode.init_game( self )
	level_started.emit()
	_tree.send_global_notification( &"LevelStarted", self )

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
