class_name CBackground extends ComponentBase

@export var bg_p1:NodePath
@export var bg_p2:NodePath
@export var speed:float = 1.0

var bg1:TextureRect
var bg2:TextureRect

func event_begin():
	bg1 = tree.get_node_from_nodepath( owner, bg_p1 )
	bg2 = tree.get_node_from_nodepath( owner, bg_p2 )

func event_tick():
	if bg2.global_position.y >= owner.get_viewport().get_visible_rect().size.y:
		bg2.global_position.y = -owner.get_viewport().get_visible_rect().size.y
	if bg1.global_position.y >= owner.get_viewport().get_visible_rect().size.y:
		bg1.global_position.y = -owner.get_viewport().get_visible_rect().size.y
	
	bg1.global_position.y += speed
	
	bg2.global_position.y += speed
