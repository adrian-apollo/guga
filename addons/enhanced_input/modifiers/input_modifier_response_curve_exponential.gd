class_name InputModifierResponseCurveExponential
extends InputModifier
## Reshapes each axis as sign(v) * |v| ^ exponent. Best for values in 0..1 (sticks, triggers).
## exponent > 1: finer control near the center (stick 0.5 -> 0.25 with exponent 2).
## exponent < 1: more sensitive near the center. 1 = no change.

@export var exponent := Vector3.ONE


func modify(value: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	return Vector3(
		_curve(value.x, exponent.x),
		_curve(value.y, exponent.y),
		_curve(value.z, exponent.z))


func _curve(v: float, e: float) -> float:
	return signf(v) * pow(absf(v), e)
