class_name InputModifierSwizzle
extends InputModifier
## Reorders axes. Order name = which input axis feeds (x, y, z) of the output.
## Example: YXZ -> output.x = input.y, output.y = input.x.

enum Order { YXZ, ZYX, XZY, YZX, ZXY }

@export var order := Order.YXZ


func modify(v: Vector3, _delta: float, _memory: Dictionary) -> Vector3:
	match order:
		Order.YXZ: return Vector3(v.y, v.x, v.z)
		Order.ZYX: return Vector3(v.z, v.y, v.x)
		Order.XZY: return Vector3(v.x, v.z, v.y)
		Order.YZX: return Vector3(v.y, v.z, v.x)
		_: return Vector3(v.z, v.x, v.y)
