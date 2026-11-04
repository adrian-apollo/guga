class_name CVariantCompare extends AITCondition

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

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	var value:Variant = aitree.parameters[ parameter_name ]
		
	match _is:
		COMPARE.EQUAL:
			if value == than:
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
