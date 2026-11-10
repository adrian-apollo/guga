class_name CNumbericCompare extends AITCondition

enum COMPARE{
	GREATHER,
	GREATHER_OR_EQUAL,
	LESS,
	LESS_OR_EQUAL,
	EQUAL
}

@export var parameter_name:StringName
@export var _is:COMPARE
@export var than:float = 0.0

func evaulate( aitree:AITreeBase, _state:AIState ) -> bool:
	# Missing parameter -> condition fails
	if !aitree.parameters.has( parameter_name ):
		return false

	var value:Variant = aitree.parameters[ parameter_name ]

	# Accept only numbers (int or float)
	if typeof( value ) != TYPE_FLOAT and typeof( value ) != TYPE_INT:
		return false

	match _is:
		COMPARE.EQUAL:
			return is_equal_approx( value, than )
		COMPARE.LESS:
			return value < than
		COMPARE.GREATHER:
			return value > than
		COMPARE.GREATHER_OR_EQUAL:
			return value >= than
		COMPARE.LESS_OR_EQUAL:
			return value <= than

	return false
