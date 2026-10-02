@tool
class_name Level extends Node

var current_player:Node
var tree:GugaTree

func _init():
	if !Engine.is_editor_hint():
		tree = Engine.get_main_loop() as GugaTree
		tree.s_level_changed.connect( _setup )
		tree.s_level_destroyed.connect( _destroy )


#region player controller managing
@export_group("Controllers")
@export var controllers_uids:Dictionary[ PlayerController, PackedScene ]

var controllers:Array[ PlayerController ]

#endregion

#region player start managing

@export_group("Player start")
@export_tool_button("Add PlayerStart2D", "2D") var playerstart2d = add_playerstart2d
@export_tool_button("Add PlayerStart3D", "3D") var playerstart3d = add_playerstart3d
@export_tool_button("Remove PlayerStart", "Clear") var delete = remove_playerstart

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

#region player spawning
@export_group("Player")
@export var player_scene:PackedScene
@export var spawn_player:bool = true
@export var possess:bool = true

func _setup( level:Level ):
	if !level == self:
		return
	if !player_scene:
		return
	if !spawn_player:
		return
	loadplayer()

func _destroy( level:Level ):
	if level == self:
		tree.s_level_changed.disconnect( _setup )
		tree.s_level_destroyed.disconnect( _destroy )

func loadplayer():
	current_player = player_scene.instantiate()
	if !is_instance_valid( current_player ):
		return
	
	add_child( current_player )
	current_player.owner = self
	
	movetostart()

func movetostart():
	var start:= get_node("PlayerStart")
	if  !is_instance_valid( start ):
		return

	current_player.global_position = start.global_position
	current_player.global_rotation = start.global_rotation
	current_player.global_scale = start.global_scale
	start.queue_free()

#endregion
