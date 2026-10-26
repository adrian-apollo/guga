class_name InputTriggerDown
extends InputTrigger
## TRIGGERED every frame while actuated. Used by default when a mapping has no triggers.


func evaluate(value: Vector3, _last_value: Vector3, _delta: float, _memory: Dictionary) -> State:
	return State.TRIGGERED if _actuated(value) else State.NONE
