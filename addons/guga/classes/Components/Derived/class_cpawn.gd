class_name CPawn extends ComponentBase

var controller:PlayerController

func event_possess( _controller:PlayerController ):
	controller = _controller

func event_unpossess():
	pass
