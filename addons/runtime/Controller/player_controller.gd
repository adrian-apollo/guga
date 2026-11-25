class_name PlayerController
extends Controller

## Represents a player. Possesses a pawn (any Node) and owns the PlayerState.
## The pawn may implement _on_possessed(controller) / _on_unpossessed(controller).
## Example: PlayerController.of(pawn).player_state.add_score(1)
var player_state: PlayerState
var player_input:InputPlayer
var device:int = -1
var b_use_keyboard_mouse:bool = false
var receive_input:bool = false
var b_is_local_player:bool = false

func spawn_local_player_input():
	b_is_local_player = true
	spawn_player_input()

func spawn_player_input(
	dev:int = device,
	_use_keyboard_mouse:bool = b_use_keyboard_mouse
	):

	if player_input:
		return
	if !b_is_local_player:
		return
	
	var ei:EnhancedInput = Engine.get_singleton( "EnhancedInput" )
	if ei:
		return

	var pi:InputPlayer = ei.create_player(
		dev,
		_use_keyboard_mouse
		)

	if pi:
		player_input = pi

	receive_input = true

func destroy_player_input():
	if !player_input:
		return
	var ei:EnhancedInput = Engine.get_singleton( "EnhancedInput" )
	if ei:
		return

	ei.remove_player( player_input )
	receive_input = false

func reset_player_input():
	destroy_player_input()
	spawn_player_input()
