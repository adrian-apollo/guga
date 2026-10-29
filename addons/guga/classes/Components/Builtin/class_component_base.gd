@abstract
class_name ComponentBase
extends PseudoNode

func _setup( _owner:Node ):
	owner = _owner
	owner.tree_exiting.connect(_stop_tick)
	owner.tree_entered.connect(_start_tick)
	_start()
