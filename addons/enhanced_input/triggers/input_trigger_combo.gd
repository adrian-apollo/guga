class_name InputTriggerCombo
extends InputTrigger
## Sequence: every action in combo_steps must trigger in order, each within step_time
## of the previous one. Then pressing this mapping's own input (in time) fires TRIGGERED.
## Step actions should use InputTriggerPressed (one-frame TRIGGERED) and belong to an active context.
## Steps are read from the previous frame (1 frame lag). Wrong inputs do not reset the combo.

@export var combo_steps: Array[InputAction] = []
## Max seconds allowed between steps.
@export var step_time := 0.5


func evaluate(value: Vector3, last_value: Vector3, delta: float, memory: Dictionary) -> State:
	var idx: int = memory.get("idx", 0)
	var timer: float = memory.get("timer", 0.0) + delta
	if idx > 0 and timer > step_time:  # too slow: reset
		idx = 0
	if idx < combo_steps.size():
		var step := _player_action(memory, combo_steps[idx])
		if step and step.state == State.TRIGGERED:
			idx += 1
			timer = 0.0
	elif _actuated(value) and not _actuated(last_value):  # final input, in time
		memory.idx = 0
		memory.timer = 0.0
		return State.TRIGGERED
	memory.idx = idx
	memory.timer = timer
	return State.ONGOING if idx > 0 else State.NONE
