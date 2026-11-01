##	Only to be instaniated by code from a pawn component

class_name AIController
extends Node

signal pawn_changed( new_pawn:Node )

var tree:GugaTree
var pawn: Node
var component_stack:ComponentStack = ComponentStack.new()

func _init():
	tree = Engine.get_main_loop()
	component_stack.owner = self

#region possession
func possess( new_pawn: Node ) -> bool:
	if !is_instance_valid( new_pawn ):
			return false
	if new_pawn == pawn:
		return false

	unpossess( pawn )
		
	var pawnc:CPawn = tree.get_component_with_method_from_actor( new_pawn, &"event_possessed")
	if !pawnc:
		return false

	if !pawnc.event_possessed( self ):
		return false

	pawn = new_pawn
	pawn_changed.emit( pawn )
	tree.send_global_notification( &"pawn_changed", [ self, pawn] )
	return true
	
func unpossess( _pawn:Node ) -> bool:
	if !pawn:
		return false
	if !_pawn:
		return false
	
	var pawnc:CPawn = tree.get_component_with_method_from_actor( _pawn, &"event_unpossessed")
	if !pawnc:
		return false

	if !pawnc.event_unpossessed( self ):
		return false
	
	pawn = null
	pawn_changed.emit( _pawn )
	tree.send_global_notification( &"pawn_changed", [ self, pawn ] )
	return true
#endregion
