extends ComponentBase
class_name CPawn

var controller:CLevelController

func _posses( controller:CLevelController ):
	tree.send_message(controller, "receivedata", ["OK"])
	controller = controller
	event_possess()
	
func _unposses():
	event_unposses()

func event_possess():
	pass
	
func event_unposses():
	pass
