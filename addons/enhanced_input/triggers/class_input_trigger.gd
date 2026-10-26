@abstract
class_name InputTrigger
extends Resource
## Base trigger. Decides if a mapping is NONE / ONGOING / TRIGGERED this frame.
## Override evaluate(). `memory` is a Dictionary private to this mapping+trigger: use it for state (timers, counters).

enum State { NONE, ONGOING, TRIGGERED }

## Minimum value length to count as "actuated".
@export var actuation_threshold := 0.5


func evaluate(_value: Vector3, _last_value: Vector3, _delta: float, _memory: Dictionary) -> State:
	return State.NONE


func _actuated(value: Vector3) -> bool:
	return value.length() >= actuation_threshold


## This player's instance of `action`, so Chorded/Combo read the state of the right player.
## `memory["player"]` is the InputPlayer instance id (set by InputPlayer).
func _player_action(memory: Dictionary, action: InputAction) -> InputAction:
	var player := instance_from_id(memory.get("player", 0)) as InputPlayer
	return player.get_action(action) if player and action else action
