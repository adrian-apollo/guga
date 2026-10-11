class_name CAIBase
extends ComponentBase

@export var enabled:bool:
	set(value):
		if value:
			enabled = true
		else:
			enabled = false
	get:
		return enabled

@export var aI_tree_scene:PackedScene

var aitree:Node

func event_begin():
	if !aI_tree_scene:
		return
	
	aitree_spawn()

func aitree_spawn():
	aitree = aI_tree_scene.instantiate()
	
	if aitree.get_script() != AITreeBase:
		aitree.queue_free()
		return
	
	owner.add_child( aitree )
	aitree.set("owner", owner)

func event_destroy():
	if aitree:
		aitree.queue_free()
