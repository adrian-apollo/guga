class_name InputAction
extends Resource
## An abstract input ("Jump", "Move"). Connect to its signals or poll value/state.
## Signals mirror UE5: started, ongoing, triggered, completed, canceled.

signal started(value: Variant)
signal ongoing(value: Variant)
signal triggered(value: Variant)
signal completed(value: Variant)
signal canceled(value: Variant)

enum ValueType {
	BOOL,
	AXIS_1D,
	AXIS_2D,
	AXIS_3D
}

@export var value_type:= ValueType.BOOL:
	set(v):
		value_type = v
		value = _convert(Vector3.ZERO)
		_last_raw = Vector3.INF  # force the next update

## If true, a higher priority context claims the input and lower contexts ignore it.
@export var consume_input:bool = true

## Applied to EVERY mapping of this action, after the mapping's own modifiers.
@export var modifiers:Array[ InputModifier ] = []

## Added to the triggers of EVERY mapping of this action (any one fires, OR).
@export var triggers: Array[ InputTrigger ] = []

## Prints every state change of this action.
@export var debug:bool = false

## Current value: bool / float / Vector2 / Vector3 depending on value_type.
var value:Variant = false
var state:InputTrigger.State = InputTrigger.State.NONE

var _last_raw:Vector3 = Vector3.INF  # raw value of the last real update; INF = never updated

## Called by EnhancedInput once per frame. Do not call manually.
func update( raw: Vector3, new_state: int ):
	if new_state == InputTrigger.State.NONE and state == InputTrigger.State.NONE and raw == _last_raw:
		return  # idle and unchanged: nothing to convert or emit

	_last_raw = raw
	var old:InputTrigger.State = state
	state = new_state as InputTrigger.State
	value = _convert( raw )
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
