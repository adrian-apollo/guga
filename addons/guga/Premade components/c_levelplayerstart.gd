class_name CLevelLoadPlayer extends ComponentBase

var level:Level
@export var player_scene:PackedScene
var playerref:Node

func tick():
	level = tree.get_current_level()
	if level:
		loadplayer()

func loadplayer():
	if !player_scene:
		print("CLevelLoadPlayer" + " >> " + "Empty player scene")
		componentmanager.delete_component(self)
		return

	print("CLevelLoadPlayer >> Starting loadind player")
	
	playerref = player_scene.instantiate()
	if !is_instance_valid( playerref ):
		print("CLevelLoadPlayer" + " >> " + "Invalid player scene reference")
		return
	
	print("CLevelLoadPlayer" + " >> " + "Adding player to level")
	
	level.add_child( playerref )
	playerref.owner = level
	#tree.send_message(owner, "posses", [playerref])
	
	movetostart()
	
	tree.call_deferred("send_message", level, "posses", [ playerref ] ) 
	
	componentmanager.delete_component( self )

func movetostart():
	var start:= level.get_node("PlayerStart")
	if  !is_instance_valid( start ):
		return

	print("CLevelLoadPlayer" + " >> " + "Moving player to start")
	playerref.global_position = start.global_position
	playerref.global_rotation = start.global_rotation
	start.queue_free()
	start.free()
