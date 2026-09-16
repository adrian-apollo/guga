@tool
class_name Level extends Node

@export_group("Configuration")
@export var component_manager:ComponentsManager
@export_tool_button("Add PlayerStart2D", "2D") var playerstart2d = add_playerstart2d
@export_tool_button("Add PlayerStart3D", "3D") var playerstart3d = add_playerstart3d
@export_tool_button("Remove PlayerStart", "Clear") var delete = remove_playerstart

func _ready() -> void:
	if component_manager and !Engine.is_editor_hint():
		component_manager.start( self )

#region player start managing
func add_playerstart2d():
	if find_child("PlayerStart"):
		print( "This level already has a PlayerStart. Delete it first before adding another one")
		return
	
	var ps = load("uid://c7iuw10w7ox4x").instantiate()
	add_child( ps )
	ps.owner = self
	ps.position = get_viewport().get_visible_rect().size / 2

func add_playerstart3d():
	if find_child("PlayerStart"):
		print( "This level already has a PlayerStart. Delete it first before adding another one")
		return
		
	var ps = load( "uid://2k1fwn8baejt" ).instantiate()
	add_child( ps )
	ps.owner = self
	
func remove_playerstart():
	if find_child("PlayerStart"):
		find_child("PlayerStart").queue_free()
		print( "PlayerStart deleted sucessfully" )
		return
	
	print("Theres no PlayerStart")

#endregion
