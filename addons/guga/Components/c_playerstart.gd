class_name CLevelStart extends ComponentBase

var level:Level
var defaultplayer:PackedScene = preload("uid://qhk8d62eqgwr")
var playerref:Node3D

func _tick():
	level = LevelManager.getcurrentlevel()
	if level:
		loadplayer()

func loadplayer():
	if level.level_game_mode.PlayerScene:
		print("PlayerStart >> Loadind player")
		playerref = level.level_game_mode.PlayerScene.instantiate()
		level.add_child( playerref )
		playerref.owner = owner
		MailServer.sendmessage.emit(owner, "posses", [playerref])
		movetostart()
		componentmanager.delete_component( self )

func movetostart():
	var start:MeshInstance3D = level.get_node("PlayerStart")
	if start:
		print("PlayerStart >> Moving player")
		playerref.global_position = start.global_position
		playerref.global_rotation.y = start.global_rotation.y
		start.queue_free()
		start.free()
