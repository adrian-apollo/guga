class_name InputTriggerTap
extends InputTrigger
## ONGOING while pressed; TRIGGERED on release if it was held <= tap_time.
## Held longer -> never fires (canceled).

@export var tap_time := 0.2


func evaluate(value: Vector3, last_value: Vector3, delta: float, memory: Dictionary) -> State:
	if _actuated(value):
		memory.held = memory.get("held", 0.0) + delta
		return State.NONE if memory.held > tap_time else State.ONGOING
	var tapped: bool = _actuated(last_value) and memory.get("held", 0.0) <= tap_time
	memory.held = 0.0
	return State.TRIGGERED if tapped else State.NONE
