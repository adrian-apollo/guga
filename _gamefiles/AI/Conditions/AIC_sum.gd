class_name AIC_NumbericCompare extends AITCondition

enum WHAT{
	GREATHER_THAN,
	LESS_THAN,
	EQUAL
}

@export var a:float
@export var _is:WHAT
@export var b:float

func evaulate( _aitree:AITreeBase, _state:AIState ) -> bool:
	match _is:
		WHAT.EQUAL:
			if a == b:
				return true
		WHAT.GREATHER_THAN:
			if a > b:
				return true
		WHAT.LESS_THAN:
			if a < b:
				return true
	return false
