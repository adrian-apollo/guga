class_name CPrintDebug extends ComponentBase2

func event_begin( ):
	print("EVENT BEGIN")
	
	await tree.create_timer(5).timeout
	tree.unlist_component(owner, self)

func event_tick():
	print("EVENT TICK" + str( get_instance_id() ) )

func event_destroy():
	print("EVENT DESTROYED")
	var newc:CPrintDebug = tree.actor_add_component( owner, CPrintDebug )
	newc._reset_tick(true, true, 1)
