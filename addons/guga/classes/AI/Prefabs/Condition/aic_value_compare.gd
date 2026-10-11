class_name CNumberCompare extends AITCondition

@export var if_value_is:COMPARE
@export var than:float = 0.0

func evaulate() -> bool:
	fetch()
	if !property:
		return false
	if property.is_class("Float"):
		match COMPARE:
			COMPARE.EQUAL:
				if property == than:
					return true
			COMPARE.LESS:
				if property < than:
					return true
			COMPARE.GREATER:
				if property > than:
					return true
	return false
