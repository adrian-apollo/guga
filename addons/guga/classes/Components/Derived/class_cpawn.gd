@abstract
class_name CPawn
extends ComponentBase

@export var auto_possess:bool = true
@export_range(0,7,1) var controller_index:int

var controller:PlayerController

func event_begin():
	if auto_possess:
		if tree.get_controller_by_index( controller_index ):
			tree.get_controller_by_index( controller_index ).possess( owner )

func _set_controller( _controller:PlayerController ):
	if _controller is PlayerController:
		controller = _controller
		return

	controller = null

func event_possess():
	pass

func event_unpossess():
	pass
