extends ComponentBase
class_name CPawn

func event_posses(controller:CLevelController):
	tree.send_message(controller, "receivedata", ["OK"])
