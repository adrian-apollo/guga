class_name InputMapping
extends Resource
## Binds one physical input (event) to an action, with optional modifiers and triggers.
## Keys/buttons produce Vector3(1,0,0) when pressed; use modifiers to move it to other axes.
## The action's own modifiers/triggers are appended to this mapping's (mapping first, then action).
## `memory` is the per-mapping state Dictionary owned by EnhancedInput (one sub-dictionary per modifier/trigger).

## Identifies this mapping for rebinding/saving (e.g. &"jump_key"). Empty = not rebindable.
## Use the same name only for mappings that must change together.
@export var mapping_name: StringName
@export var action: InputAction
## InputEventKey, InputEventMouseButton, InputEventMouseMotion, InputEventJoypadButton,
## InputEventJoypadMotion, InputEventScreenTouch (touch button) or InputEventScreenDrag (touch drag).
@export var event: InputEvent
## Touch only: screen area where the finger must start, as fractions of the viewport (x, y, w, h).
@export var touch_zone := Rect2(0.0, 0.0, 1.0, 1.0)
@export var modifiers: Array[InputModifier] = []
## Empty (also without action triggers) = behaves like InputTriggerDown. Several triggers: any one fires (OR).
@export var triggers: Array[InputTrigger] = []


func apply_modifiers(value: Vector3, delta: float, memory: Dictionary) -> Vector3:
	var chain: Array = (modifiers + action.modifiers) if action else modifiers
	for m in chain:
		if m:
			value = m.modify(value, delta, _sub(memory, m))
	return value


func evaluate(value: Vector3, last_value: Vector3, delta: float, memory: Dictionary) -> InputTrigger.State:
	var chain: Array = (triggers + action.triggers) if action else triggers
	if chain.is_empty():
		return InputTrigger.State.TRIGGERED if value.length() >= 0.5 else InputTrigger.State.NONE
	var result := InputTrigger.State.NONE
	for t in chain:
		if t:
			var s: int = t.evaluate(value, last_value, delta, _sub(memory, t))
			result = maxi(result, s) as InputTrigger.State
	return result


## State Dictionary of one modifier/trigger. It carries the "player" id (see InputTrigger._player_action).
func _sub(memory: Dictionary, key: Resource) -> Dictionary:
	if not memory.has(key):
		memory[key] = {"player": memory.get("player", 0)}
	return memory[key]
