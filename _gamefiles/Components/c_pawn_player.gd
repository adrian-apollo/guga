class_name CPawnPlayer extends CPawn

func event_possess():
	tree.execute( owner, &"allow_inputs", [ true ] )
	tree.execute( owner, &"_activate_spawner", [])
