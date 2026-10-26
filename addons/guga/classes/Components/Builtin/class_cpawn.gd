@abstract
class_name CPawn
extends ComponentBase

@export_group( "Pawn" )
@export var auto_possess:bool = true
@export_range(0,7,1) var controller_index:int

func event_begin():
	if auto_possess:
		if tree.get_controller_by_index( controller_index ):
			tree.get_controller_by_index( controller_index ).possess( owner )

##	fired when a controllers calls it
func event_possess():
	pass

func event_unpossess():
	pass
