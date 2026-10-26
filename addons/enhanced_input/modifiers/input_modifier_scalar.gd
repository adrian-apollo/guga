class_name InputModifierScalar
extends InputModifier
## Multiplies the value per axis (e.g. sensitivity).

@export var scalar := Vector3.ONE


func modify(value: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	return value * scalar
