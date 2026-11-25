class_name PlayerState extends Resource
## Per-player data (name, id, score). Owned by GameState, one per player.
## Example: player_controller.player_state.add_score(10)

@export var player_name:String = "Player"

signal score_changed( new_score: float )

var name:StringName = &"PlayerState"
var player_id :int = 0
var controller: PlayerController
var score:float = 0:
	set(value):
		score = value
		score_changed.emit(score)

func add_score( amount:float ):
	score += amount
