@abstract
class_name PlayerController
extends Node

#region	signals
signal s_possession( Node )
signal s_unpossession( Node )
#endregion

#region	properties
var tree:GugaTree
var possessed_pawn:Node = null
var level:Level
var id:int
#endregion

#region

func _init():
	tree = Engine.get_main_loop()

#endregion

#region	external methods

func possess(actor:Node):
	s_possession.emit( actor )
	possessed_pawn = actor
	
func unpossess(actor:Node):
	s_unpossession.emit( actor )
	possessed_pawn = null

#endregion
