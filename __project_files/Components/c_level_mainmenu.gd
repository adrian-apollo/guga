class_name C_UI_Level_Mainmenu extends ComponentBase

func event_begin():
	##	screen blur effect
	tree.get_gamemode().uis[0].add_widget_to_layer(
		load("uid://1x441e255mnh").instantiate(),
		"effects3")
