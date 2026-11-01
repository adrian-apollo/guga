class_name GameState extends Resource
## Shared match data: match state, elapsed time, list of PlayerStates.
## Example: if game_state.match_state == GameState.IN_PROGRESS: ...

signal match_state_changed(new_state: StringName)
signal player_state_added(player_state: PlayerState)
signal player_state_removed(player_state: PlayerState)

enum MATCH_STATE {
	WAITING_TO_START,
	IN_PROGRESS,
	WAITING_POST_MATCH
}

var player_array: Array[PlayerState] = []
var elapsed_time := 0.0
var match_state:MATCH_STATE = MATCH_STATE.WAITING_TO_START:
	set(value):
		if value == match_state:
			return
		match_state = value
		match_state_changed.emit(match_state)

var tree:GugaTree
var level:Level

func _init():
	tree = Engine.get_main_loop()

func _count_time() -> void:
	if match_state == MATCH_STATE.IN_PROGRESS:
		elapsed_time += level.get_process_delta_time()

func add_player_state( player_state: PlayerState ):
	player_array.append( player_state )
	player_state_added.emit( player_state )

func remove_player_state( player_state:PlayerState ):
	player_array.erase(player_state)
	player_state_removed.emit(player_state)
	player_state.queue_free()
	
func free():
	if tree.process_frame.is_connected(_count_time):
		tree.process_frame.disconnect( _count_time )
