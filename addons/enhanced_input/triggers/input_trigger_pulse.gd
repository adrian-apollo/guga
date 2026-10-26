class_name InputTriggerPulse
extends InputTrigger
## While held, TRIGGERED every `interval` seconds (ONGOING in between).

@export var interval := 0.2
## Fire immediately on the first frame.
@export var trigger_on_start := true
## Max number of pulses per press. 0 = unlimited.
@export var trigger_limit := 0


func evaluate(value: Vector3, _last_value: Vector3, delta: float, memory: Dictionary) -> State:
	if not _actuated(value):
		memory.clear()
		return State.NONE
	if trigger_limit > 0 and memory.get("count", 0) >= trigger_limit:
		return State.NONE
	if not memory.has("count"):
		memory.elapsed = 0.0
		memory.count = 1 if trigger_on_start else 0
		return State.TRIGGERED if trigger_on_start else State.ONGOING
	memory.elapsed += delta
	if memory.elapsed < interval:
		return State.ONGOING
	memory.elapsed -= interval
	memory.count += 1
	return State.TRIGGERED
