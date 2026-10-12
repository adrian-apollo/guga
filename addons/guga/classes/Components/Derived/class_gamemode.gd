class_name GameModeBase extends PseudoNode

@export var player_with_controller:Array[ ControllerDuo ]

var controllers:Array[ PlayerController ]
var players:Array[ Node ]

#region
func _setup_local_to_scene():
	owner = get_local_scene()
	if !owner.ready.is_connected(_setup):
		owner.ready.connect(_setup, 4)
	controllers.resize( 8 )
	players.resize( 8 )

func _setup():
	for i in player_with_controller.size():
		#	spawn players
		if player_with_controller[i].player_scene:	
			players[i] = player_with_controller[i].player_scene.instantiate()
			owner.add_child(players[i])
			players[i].owner = owner
			players[i].name = "PLAYER_" + str(i)
		#	create controllers
		if player_with_controller[i].controller:
			controllers[i] = player_with_controller[i].controller.duplicate(true)
			#	possess players
			if players[i]:
				tree.execute( players[i], &"event_possess", [ controllers[i] ] )
	
	_teleport_players()

func _teleport_players():
	var playerstarts:Array[Node] = owner.find_children( "PlayerStart_*", &"PlayerStart", false, true)
	for ps in playerstarts:
		if players[ ps.player_number ]:
			players[ ps.player_number ].set_global_position( ps.get_global_position())
			ps.queue_free()
#endregion
