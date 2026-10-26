class_name InputTriggerReleased
extends InputTrigger
## TRIGGERED only on the frame the input stops being actuated.


func evaluate(value: Vector3, last_value: Vector3, _delta: float, _memory: Dictionary) -> State:
	var fired := _actuated(last_value) and not _actuated(value)
	return State.TRIGGERED if fired else State.NONE
