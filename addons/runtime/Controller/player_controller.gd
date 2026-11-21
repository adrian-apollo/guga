class_name PlayerController
extends Controller

## Represents a player. Possesses a pawn (any Node) and owns the PlayerState.
## The pawn may implement _on_possessed(controller) / _on_unpossessed(controller).
## Example: PlayerController.of(pawn).player_state.add_score(1)
var player_state: PlayerState
