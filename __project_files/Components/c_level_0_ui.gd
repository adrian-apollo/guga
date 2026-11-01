class_name CUILevel0 extends ComponentBase

var level:Level
var levelui:UIBase

func event_begin():
	if owner.get_script() != Level:
		return
	level = owner
	
	if !level._ui:
		return
	levelui = level._ui
	
	add_widgets()

func add_widgets():
	levelui.add_widget_to_layer( 
		load("uid://b2pru0llhpe6b").instantiate(),
		"indicators")
	levelui.add_widget_to_layer(
		load("uid://chqmihnkr47kd").instantiate(),
		"gameplay_menus")
	
	##	screen blur effect
	levelui.add_widget_to_layer(
		load("uid://1x441e255mnh").instantiate(),
		"effects3")
