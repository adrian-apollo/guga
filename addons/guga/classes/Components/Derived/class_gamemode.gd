class_name GameModeBase
extends PseudoNode

@export var players_scenes:Array[ PackedScene ]
@export var controller_class:PlayerController
@export var ui_scene:PackedScene

var controllers:Array[ PlayerController ] = []
var players:Array[ Node ] = []
var uis:Array[ UIBase ] = []

#region
func _setup_local_to_scene():
	owner = get_local_scene()
	if !owner.ready.is_connected(_setup):
		owner.ready.connect(_setup, 4)
	
	controllers.resize( 8 )
	players.resize( 8 )
	players_scenes.resize(8)
	players_scenes.resize(8)
	uis.resize(8)

func _setup():
	_create_controllers()
	_spawn_players()
	_spawn_uis()
	_teleport_players()

func _create_controllers():
	if !controller_class:
		return
	for n in 7:
		controllers[n] = controller_class.duplicate( true )

func _spawn_uis():
	if !ui_scene:
		return
	var newui:UIBase = ui_scene.instantiate()
	if is_instance_valid( newui ):
		owner.add_child( newui )
		newui.hide()
		if !newui is UIBase:
			uis[0].queue_free()
			return
		newui.owner = owner
		uis[0] = newui
		uis[0].show()

func _spawn_players():
	for n in 7:
		if !players_scenes[n]:
			return

		players[n] = players_scenes[n].instantiate()
		owner.add_child( players[n] )
		players[n].owner = owner
		players[n].name = "PLAYER_" + str(n)

func _teleport_players():
	var playerstarts:Array[Node] = owner.find_children( "PlayerStart_*", &"PlayerStart", false, true)
	for ps in playerstarts:
		if players[ ps.player_number ]:
			players[ ps.player_number ].set_global_position( ps.get_global_position())
			ps.queue_free()
#endregion
