class_name Is_Valid extends AITCondition

var node:Node = null
	
func evaulate() -> bool:
	if is_instance_valid( node ):
		return true

	return false
