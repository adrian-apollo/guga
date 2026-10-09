class_name IsValid extends AITCondition

func evaulate() -> bool:
	if is_instance_valid( aitree.owner ):
		return true
	return false
