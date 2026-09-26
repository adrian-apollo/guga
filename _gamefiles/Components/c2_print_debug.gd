class_name CPrintDebug extends ComponentBase2

func event_begin( ):
	print("EVENT BEGIN")
	
	await tree.create_timer(5).timeout
	tree.unlist_component(owner, self)

func event_tick():
	print(get_reference_count())
	print(tree.listed_actors)
	print("EVENT TICK")
	
func event_destroy():
	print("EVENT DESTROYED")
