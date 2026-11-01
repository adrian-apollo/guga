class_name CNumbericCompare extends AITCondition

enum COMPARE{
	GREATHER,
	GREATHER_OR_EQUAL,
	LESS,
	LESS_OR_EQUAL,
	EQUAL
}

@export var bb_property:StringName
@export var _is:COMPARE
@export var than:float = 0.0

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	var value: = aitree.blackboard.get( bb_property )
	if !value:
		return false
	if value.is_class("Float"):
		match COMPARE:
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
