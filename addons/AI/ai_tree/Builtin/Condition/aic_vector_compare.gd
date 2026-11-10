class_name AITCVectorCompare extends AITCondition

enum COMPARE{
	DIFFERENT,
	GREATHER,
	GREATHER_OR_EQUAL,
	LESS,
	LESS_OR_EQUAL,
	EQUAL
}

@export var parameter_name1:StringName
@export var _is:COMPARE
@export var parameter_name2:StringName

func evaulate( aitree:AITreeBase, _state:AIState ) -> bool:
	if !aitree.parameters.has( parameter_name1):
		print( aitree.parameters )
		return false
	if !aitree.parameters.has( parameter_name2):
		return false

	var vector1:Vector3 = to_vector3( aitree.parameters[ parameter_name1 ] )
	var vector2:Vector3 = to_vector3( aitree.parameters[ parameter_name2 ] )

	match _is:
		COMPARE.DIFFERENT:
			if vector1 != vector2:
				return true
		COMPARE.EQUAL:
			if vector1.is_equal_approx( vector2 ):
				return true
		COMPARE.LESS:
			if vector1 < vector2:
				return true
		COMPARE.GREATHER:
			if vector1 > vector2:
				return true
		COMPARE.GREATHER_OR_EQUAL:
			if vector1 >= vector2:
				return true
		COMPARE.LESS_OR_EQUAL:
			if vector1 <= vector2:
				return true
	return false

func to_vector3( vector:Variant ) -> Vector3:
	if vector is Vector3:
		return vector

	if vector is Vector2:
		return Vector3( vector.x, vector.y, 0)
	
	return Vector3()