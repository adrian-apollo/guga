class_name InputModifierDeadZone
extends InputModifier
## Ignores small values and rescales [lower, upper] to [0, 1].

enum Type { AXIAL, RADIAL }

@export var type := Type.RADIAL
@export_range(0.0, 1.0) var lower := 0.2
@export_range(0.0, 1.0) var upper := 1.0


func modify(value: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	if type == Type.RADIAL:
		return value.normalized() * _remap(value.length())
	return Vector3(_signed(value.x), _signed(value.y), _signed(value.z))


func _remap(length: float) -> float:
	if length < lower:
		return 0.0
	return clampf(inverse_lerp(lower, upper, length), 0.0, 1.0)


func _signed(v: float) -> float:
	return signf(v) * _remap(absf(v))
