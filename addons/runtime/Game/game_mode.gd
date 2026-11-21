class_name GameMode extends Resource
## Game rules: creates GameState, logs players in, spawns pawns, starts/ends the match.
## Put one as a child of a Level to customize it (or extend this script).
## Example: game_mode.login("Ana") -> new PlayerController with its pawn.

##	Start the match automatically when the level is ready to play
@export var auto_start_match:bool = true
##	Class reference for a GameState derived resource that stores data about the current game
@export var game_state_class:GameState
##	Number of players to spawn on this level
@export var initial_players:int = 1
##	This is the default scene that will be created for every player if a custom one has not been set
@export var default_pawn_scene:PackedScene
@export_file("*.gd") var ui_class:String = "uid://dfapohvjuuwvg"
##	An array of scenes to choose over the default one, the index matches the pawn and controller
@export var per_player_pawn_scenes:Array[ PackedScene ]
##	Class reference to a player controller derived class 
@export_file("*.gd") var player_controller_class:String = "uid://b55oyviiyrkhv"
##	Class reference for a player state stored inside the player controller
@export var player_state_class:PlayerState

signal match_started
signal match_ended
signal player_joined( controller: PlayerController )
signal player_left( controller: PlayerController )

#	public
var level:Level
var game_state:GameState
var controllers:Array[ PlayerController ] = []

#	private
var _next_player_id:int = 0
var _next_start:int = 0
var tree:GugaTree

func _init():
	if !Engine.is_editor_hint():
		tree = Engine.get_main_loop()

## Called by Level once it is ready and active.
func init_game( _level:Level ):
	if _level != get_local_scene():
		return

	level = _level
	
	if !game_state_class:
		return
	
	game_state = game_state_class.duplicate( true )
	game_state.level = _level
	tree.process_frame.connect( game_state._count_time )
	create_ui()
	
	for i in initial_players:
		login()

	if auto_start_match:
		start_match()

func login( player_name := "" ) -> PlayerController:
	if !player_state_class or !player_controller_class:
		return null

	#	create the PlayerState
	var ps:PlayerState = player_state_class.duplicate( true )
	ps.player_id = _next_player_id
	ps.player_name = player_name if player_name else "Player%d" % ps.player_id
	ps.name = "PlayerState%d" % ps.player_id
	_next_player_id += 1
	
	#	create the PlayerController
	var pc:Node = load( player_controller_class ).new()
	level.add_child( pc, true )
	pc.name = "PlayerController%d" % ps.player_id
	pc.player_state = ps
	ps.controller = pc
	
	game_state.add_player_state( ps )
	controllers.append( pc )
	restart_player( pc )
	player_joined.emit( pc )
	tree.send_global_notification( &"player_joined", pc )
	return pc

func logout( pc:PlayerController ):
	if !controllers.has( pc ):
		return

	player_left.emit( pc )
	tree.send_global_notification( &"player_left", pc)
	if pc.pawn:
		pc.pawn.queue_free()
	game_state.remove_player_state( pc.player_state )
	pc.player_state.controller = null
	pc.player_state = null
	controllers.erase( pc )

## Spawns a new pawn for the controller (replaces the current one).
func restart_player( pc:PlayerController ):
	var old_pawn:Node = pc.pawn
	if old_pawn:
		old_pawn.queue_free()

	var new_pawn:Node = spawn_default_pawn( pc )
	if new_pawn:
		pc.possess( new_pawn )	

func spawn_default_pawn( pc: PlayerController ) -> Node:
	if not default_pawn_scene:
		return null

	var pawn:Node = default_pawn_scene.instantiate()
	level.add_child( pawn )
	pawn.owner = level

	var start:PlayerStart = choose_player_start( pc )
	if start and "global_transform" in pawn:
		start.hide()
		pawn.global_transform = start.global_transform
		start.controller = pc
	return pawn

func create_ui():
	if ui_class.is_empty():
		return
	if !ResourceLoader.exists( ui_class ):
		return
	
	var scr:GDScript = load( ui_class )
	if scr != UIBase:
		return
	
	var newui:UIBase = scr.new() 
	level.add_child( newui )
	newui.owner = level
	level._ui = newui
	newui.name = "UI"

## Override to change the spawn rule. Default: round-robin over player starts.
func choose_player_start( _pc: PlayerController ) -> Node:
	var start:PlayerStart = level.find_child( "PlayerStart_" + str( _pc.player_state.player_id ) )
	return start

func start_match():
	if game_state.match_state == GameState.MATCH_STATE.IN_PROGRESS:
		return
	game_state.match_state = GameState.MATCH_STATE.IN_PROGRESS
	match_started.emit()
	tree.send_global_notification( &"match_started" )

func end_match():
	if game_state.match_state != GameState.MATCH_STATE.IN_PROGRESS:
		return
	game_state.match_state = GameState.MATCH_STATE.WAITING_POST_MATCH
	match_ended.emit()
	tree.send_global_notification( &"match_ended" )
