class_name InputTriggerHold
extends InputTrigger
## ONGOING while held, TRIGGERED once held for hold_time. Released early -> canceled.

@export var hold_time := 0.5
## If true, fires a single frame instead of every frame while still held.
@export var is_one_shot := false


func evaluate(value: Vector3, _last_value: Vector3, delta: float, memory: Dictionary) -> State:
	if not _actuated(value):
		memory.clear()
		return State.NONE
	memory.held = memory.get("held", 0.0) + delta
	if memory.held < hold_time:
		return State.ONGOING
	if is_one_shot and memory.get("fired", false):
		return State.NONE
	memory.fired = true
	return State.TRIGGERED
