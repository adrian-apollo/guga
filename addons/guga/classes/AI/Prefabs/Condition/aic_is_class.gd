class_name CIsActorIsValid extends AITCondition

func evaulate() -> bool:
	super()
	if property.is_class( "Node" ):
		if is_instance_valid( actor ):
			return true
	return false
