class_name InputModifierNegate
extends InputModifier
## Inverts the selected axes.

@export var x := true
@export var y := true
@export var z := true


func modify(value: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	return Vector3(
		-value.x if x else value.x,
		-value.y if y else value.y,
		-value.z if z else value.z)
