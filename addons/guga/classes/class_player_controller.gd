class_name PlayerController
extends PseudoNode

#region	signals
signal s_possessed( Node )
signal s_unpossessed( Node )
#endregion

#region	properties
var pawn:Node = null
var level:Level
var id:int
#endregion

#region

func _init():
	tree = Engine.get_main_loop()

#endregion

#region	external methods

func possess( actor:Node ):
	if is_instance_valid( actor):
		s_possessed.emit( actor )
		tree.execute( actor, &"event_possess", [])
		tree.execute( actor, &"_set_controller", [ self ])
		pawn = actor
	
func unpossess(actor:Node):
	if is_instance_valid( actor):
		s_unpossessed.emit( actor )
		pawn.call(&"event_possess")
		pawn = null

#endregion
