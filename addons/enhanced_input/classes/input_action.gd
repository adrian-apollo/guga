class_name InputAction
extends Resource
## An abstract input ("Jump", "Move"). Connect to its signals or poll value/state.
## Signals mirror UE5: started, ongoing, triggered, completed, canceled.

signal started(value)
signal ongoing(value)
signal triggered(value)
signal completed(value)
signal canceled(value)

enum ValueType { BOOL, AXIS_1D, AXIS_2D, AXIS_3D }

@export var value_type := ValueType.BOOL:
	set(v):
		value_type = v
		value = _convert(Vector3.ZERO)
## If true, a higher priority context claims the input and lower contexts ignore it.
@export var consume_input := true
## Applied to EVERY mapping of this action, after the mapping's own modifiers.
@export var modifiers: Array[InputModifier] = []
## Added to the triggers of EVERY mapping of this action (any one fires, OR).
@export var triggers: Array[InputTrigger] = []
## Prints every state change of this action.
@export var debug := false

## Current value: bool / float / Vector2 / Vector3 depending on value_type.
var value: Variant = false
var state := InputTrigger.State.NONE


## Called by EnhancedInput once per frame. Do not call manually.
func update(raw: Vector3, new_state: int) -> void:
	var old := state
	state = new_state as InputTrigger.State
	value = _convert(raw)
	if debug and old != state:
		print("[InputAction %s] %s -> %s | value=%s" % [
			resource_name, InputTrigger.State.keys()[old],
			InputTrigger.State.keys()[state], value])
	if old == InputTrigger.State.NONE and state != InputTrigger.State.NONE:
		started.emit(value)
	match state:
		InputTrigger.State.TRIGGERED: triggered.emit(value)
		InputTrigger.State.ONGOING: ongoing.emit(value)
		_:
			if old == InputTrigger.State.TRIGGERED: completed.emit(value)
			elif old == InputTrigger.State.ONGOING: canceled.emit(value)


func _convert(v: Vector3) -> Variant:
	match value_type:
		ValueType.BOOL: return v.length() >= 0.5
		ValueType.AXIS_1D: return v.x
		ValueType.AXIS_2D: return Vector2(v.x, v.y)
		_: return v
