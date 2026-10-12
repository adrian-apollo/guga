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

func possess(actor:Node):
	s_possessed.emit( actor )
	pawn = actor
	
func unpossess(actor:Node):
	s_unpossessed.emit( actor )
	pawn = null

#endregion
