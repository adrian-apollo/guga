@abstract
class_name AITCondition extends AITElement
@export_group("Property name")

@export var watcher_property_name:StringName

var property

func fetch():
	property = aitree.get_watcher_property( watcher_property_name )

func evaulate( aitree:AITreeBase, state:AIState ) -> bool:
	return true
