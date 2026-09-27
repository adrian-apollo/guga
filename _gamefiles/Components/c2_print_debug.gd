class_name CPrintDebug extends ComponentBase2

func event_begin( ):
	print("EVENT BEGIN")
	
	await tree.create_timer(5).timeout
	#tree.unlist_component(owner, self)
	#await tree.create_timer(5).timeout
	var newc:ComponentBase2 = ComponentBase2.new()
	var scr:Script = ResourceLoader.load("uid://ibschcbn25t4")
	newc.set_script(scr)
	tree.list_component(owner, newc)

func event_tick():
	print(get_reference_count())
	print(tree.listed_actors)
	print("EVENT TICK")
	
func event_destroy():
	print("EVENT DESTROYED")
