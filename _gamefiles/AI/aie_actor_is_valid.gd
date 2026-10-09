class_name Is_Valid extends AITCondition

var node:Node = null

func evaulate() -> bool:
	print( aitree.owner )
	if is_instance_valid( aitree.owner ):
		return true
	return false
