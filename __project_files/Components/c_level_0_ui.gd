class_name CUILevel0 extends ComponentBase

func event_begin():
	tree.get_gamemode().uis[0].add_widget_to_layer( 
		load("uid://b2pru0llhpe6b").instantiate(),
		"indicators")
	tree.get_gamemode().uis[0].add_widget_to_layer(
		load("uid://chqmihnkr47kd").instantiate(),
		"gameplay_menus")
	
	##	screen blur effect
	tree.get_gamemode().uis[0].add_widget_to_layer(
		load("uid://1x441e255mnh").instantiate(),
		"effects3")

func pause():
	print("paused")
