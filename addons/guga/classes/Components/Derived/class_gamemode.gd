class_name GameMode extends PseudoNode

@export var player_with_controller:Array[ ControllerDuo ]

var duo:Dictionary[ PlayerController, Node ]

#region setup
func _setup_local_to_scene():
	owner = get_local_scene()
	if !owner.ready.is_connected(_setup):
		owner.ready.connect(_setup, 4)

func _setup():
	_create_controllers()
	_spawn_players()
	_possess()
#endregion

#region player
func _spawn_players():
	for p in player_with_controller:
		p.player_scene.instantiate()

func _create_controllers():
	pass

func _possess():
	pass

func _search_player_start():
	_teleport_player()

func _teleport_player():
	pass	
#endregion
