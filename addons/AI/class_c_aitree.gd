class_name C_AI_Tree extends ComponentBase

@export var autostart:bool = true
@export var ai_tree_scene:String

var aitree:AITreeBase
var aicontroller:AIController

func event_begin():
	if owner is not AIController:
		return
	
	aicontroller = owner
	if ai_tree_scene.is_empty():
		return

	aicontroller.pawn_changed.connect( _spawn_aitree )

	_spawn_aitree( aicontroller.pawn )

func _spawn_aitree( pawn:Node ):
	if !is_instance_valid( pawn ):
		_destroy_aitree()
		return

	var new = load( ai_tree_scene ).instantiate()
	
	if new.get_script() != AITreeBase:
		new.queue_free()
		return
	
	aitree = new
	aitree.pawn = aicontroller.pawn
	aitree.aicontroller = aicontroller
	
	aicontroller.add_child( aitree )
	aitree.set( "owner", aicontroller )

func _destroy_aitree():
	if aitree:
		aitree.queue_free()

func event_destroy():
	_destroy_aitree()
