class_name CIsPropertyNull extends AITCondition

func evaulate() -> bool:
	fetch()
	if !property:
		return true
	return false
