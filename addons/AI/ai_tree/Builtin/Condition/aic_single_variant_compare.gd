class_name CSingleVariantCompare extends AITCondition

enum COMPARE{
	DIFFERENT,
	GREATHER,
	GREATHER_OR_EQUAL,
	LESS,
	LESS_OR_EQUAL,
	EQUAL
}

@export var parameter_name:StringName

@export var _is:COMPARE
@export var than:Variant

func evaulate( aitree:AITreeBase, _state:AIState ) -> bool:
	if !aitree.parameters.has( parameter_name):
		return false

	var value:Variant = aitree.parameters[ parameter_name ]
		
	match _is:
		COMPARE.DIFFERENT:
			if value != than:
				return true
		COMPARE.EQUAL:
			if value.is_equal_approx( than ):
				return true
		COMPARE.LESS:
			if value < than:
				return true
		COMPARE.GREATHER:
			if value > than:
				return true
		COMPARE.GREATHER_OR_EQUAL:
			if value >= than:
				return true
		COMPARE.LESS_OR_EQUAL:
			if value <= than:
				return true
	return false
