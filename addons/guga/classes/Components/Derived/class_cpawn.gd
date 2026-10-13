@abstract
class_name CPawn extends ComponentBase

@export var auto_possess:bool = true
@export_range(0,7,1) var controller_index:int

var controller:PlayerController

func event_begin():
	if auto_possess:
		tree.get_controller_by_index( controller_index ).possess( owner )

func event_possess( _controller:PlayerController ):
	controller = _controller

func event_unpossess():
	pass
