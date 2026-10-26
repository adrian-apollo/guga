class_name InputModifierResponseCurveUserDefined
extends InputModifier
## Reshapes each axis with a Curve resource (edit it in the Inspector).
## Curve X axis = |input| (0..1), Y axis = output. The sign of the input is kept.
## An axis without curve is left unchanged.

@export var curve_x: Curve
@export var curve_y: Curve
@export var curve_z: Curve


func modify(value: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	return Vector3(_apply(curve_x, value.x), _apply(curve_y, value.y), _apply(curve_z, value.z))


func _apply(curve: Curve, v: float) -> float:
	if curve == null:
		return v
	return signf(v) * curve.sample(clampf(absf(v), 0.0, 1.0))
