class_name InputModifierScaleByDelta
extends InputModifier
## Multiplies the value by the frame delta (physics delta if update_mode is PHYSICS).
## Turns "units per second" into "units per frame", independent of frame rate.
## Note: the result is small, so triggers/BOOL actions with the 0.5 threshold will not fire.
## Read `action.value` or lower InputTrigger.actuation_threshold.


func modify(value: Vector3, delta: float, _memory: Dictionary) -> Vector3:
	return value * delta
