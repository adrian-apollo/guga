class_name CIsValid extends AITCondition

func evaulate() -> bool:
	if is_instance_valid( aitree.owner ):
		return true
	return false
