class_name InputTriggerPressed
extends InputTrigger
## TRIGGERED only on the frame the input becomes actuated.


func evaluate(value: Vector3, last_value: Vector3, _delta: float, _memory: Dictionary) -> State:
	var fired := _actuated(value) and not _actuated(last_value)
	return State.TRIGGERED if fired else State.NONE
