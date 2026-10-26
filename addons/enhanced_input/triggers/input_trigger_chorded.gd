class_name InputTriggerChorded
extends InputTrigger
## TRIGGERED while actuated AND chord_action is TRIGGERED (e.g. Shift + Click).
## chord_action must belong to an active context. It is read from the previous frame (1 frame lag).

@export var chord_action: InputAction


func evaluate(value: Vector3, _last_value: Vector3, _delta: float, memory: Dictionary) -> State:
	var chord := _player_action(memory, chord_action)
	var chord_on := chord != null and chord.state == State.TRIGGERED
	return State.TRIGGERED if chord_on and _actuated(value) else State.NONE
