class_name InputModifierSmooth
extends InputModifier
## Smooths the value over time (exponential approach to the target). Higher speed = faster response.
## Note: after release the value fades out, so triggers stay active a few frames.

@export var speed := 10.0


func modify(value: Vector3, delta: float, memory: Dictionary) -> Vector3:
	var current: Vector3 = memory.get("current", Vector3.ZERO)
	current = current.lerp(value, 1.0 - exp(-speed * delta))
	memory.current = current
	return current
