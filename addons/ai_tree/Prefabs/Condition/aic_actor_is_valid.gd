class_name CIsOfBuiltInClass extends AITCondition

@export var built_in_class:String = "Node"

func evaulate() -> bool:
	fetch()
	if !property:
		return false
	if property.is_class( built_in_class ):
			return true
	return false
