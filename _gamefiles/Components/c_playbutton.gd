class_name CPlayButton extends ComponentBase

@export var button_path:NodePath
@export var next_level_path:String

var btn:Button

func event_begin():
	btn = tree.get_node_from_nodepath(owner, button_path )
	if btn:
		btn.pressed.connect(event_play, 4)

func event_play():
	var newl:Level = tree.load_level( next_level_path )
	tree.change_to_level( newl, true )
