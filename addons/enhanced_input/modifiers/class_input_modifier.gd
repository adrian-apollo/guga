@abstract
class_name InputModifier
extends Resource
## Base modifier. Transforms the raw value before triggers evaluate it.
## Override modify(). Modifiers run in array order. `memory` is private to this mapping+modifier.


func modify(value: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	return value
