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
	
	print("PlayerStart >> Loadind player")
	playerref = level.level_game_mode.PlayerScene.instantiate()
	level.add_child( playerref )
	playerref.owner = owner
	tree.send_message(owner, "posses", [playerref])
	movetostart()
	componentmanager.delete_component( self )

func movetostart():
	var start:= level.get_node("PlayerStart")
	if start:
		print("PlayerStart >> Moving player")
		playerref.global_position = start.global_position
		playerref.global_rotation.y = start.global_rotation.y
		start.queue_free()
		start.free()
