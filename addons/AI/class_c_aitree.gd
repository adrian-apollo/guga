class_name C_AI_Tree extends ComponentBase

@export var autostart:bool = true
@export var ai_tree_scene:String

var aitree:AITreeBase
var aicontroller:AIController

func event_begin():
	if owner.get_script() != AIController:
		return
	
	aicontroller = owner
	
	if ai_tree_scene.is_empty():
		return
	
	
	aicontroller.s_possessed.connect( _spawn_aitree )
	aicontroller.s_unpossessed.connect( _destroy_aitree )
	
	if aicontroller.pawn:
		_spawn_aitree( null )

func _spawn_aitree( pawn ):
	var new = load( ai_tree_scene ).instantiate()
	
	if new.get_script() != AITreeBase:
		new.queue_free()
		return
	
	aitree = new
	aicontroller.add_child( aitree )
	aitree.set( "owner", aicontroller )
	
	aitree.pawn = aicontroller.pawn
	aitree.aicontroller = aicontroller

func _destroy_aitree( pawn:Node ):
	if aitree:
		aitree.queue_free()

func event_destroy():
	_destroy_aitree( null )
