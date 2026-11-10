class_name AITCDualVariantCompare extends AITCondition

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

	var value1:Variant = aitree.parameters[ parameter_name1 ]
	var value2:Variant = aitree.parameters[ parameter_name2 ]

	match _is:
		COMPARE.DIFFERENT:
			if value1 != value2:
				return true
		COMPARE.EQUAL:
			if value1.is_equal_approx( value2 ):
				return true
		COMPARE.LESS:
			if value1 < value2:
				return true
		COMPARE.GREATHER:
			if value1 > value2:
				return true
		COMPARE.GREATHER_OR_EQUAL:
			if value1 >= value2:
				return true
		COMPARE.LESS_OR_EQUAL:
			if value1 <= value2:
				return true
	return false
