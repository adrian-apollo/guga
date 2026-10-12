@tool
class_name Level extends Node

var current_player:Node
var tree:GugaTree

func _init():
	if !Engine.is_editor_hint():
		tree = Engine.get_main_loop() as GugaTree

func _ready():
	pass

#region player start managing

@export_group("Player start")
@export_tool_button("Add PlayerStart2D", "2D") var playerstart2d = add_playerstart2d
@export_tool_button("Add PlayerStart3D", "3D") var playerstart3d = add_playerstart3d

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

#region configuration
@export_group("Configuration")
@export var components:ComponentStack
@export var game_mode:GameModeBase
#endregion
