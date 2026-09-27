class_name CPrintDebug extends ComponentBase2

func event_begin( ):
	print("EVENT BEGIN")
	
	await tree.create_timer(1).timeout
	#tree.unlist_component(owner, self)

func event_tick():
	print("EVENT TICK" + str( get_instance_id() ) )

func event_destroy():
	print("EVENT DESTROYED")
	#var newc:ComponentBase2 = CPrintDebug.new()
	#tree.list_component(owner, newc)
