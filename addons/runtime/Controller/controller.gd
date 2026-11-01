@abstract
class_name Controller
extends Resource

signal pawn_changed( new_pawn:Node )

var name:StringName
var pawn: Node
var tree:GugaTree

func _init():
	tree = Engine.get_main_loop()

func possess( new_pawn: Node ) -> bool:
	if !is_instance_valid( new_pawn ):
			return false
	if new_pawn == pawn:
		return false

	unpossess()
		
	if !tree.get_component_with_method_from_actor( new_pawn, &"event_possessed"):
		return false

	tree.execute( new_pawn, &"event_possessed", [self] )

	pawn = new_pawn
	pawn_changed.emit( pawn )
	tree.send_global_notification( &"pawn_changed", [ self, pawn] )
	return true
	
func unpossess() -> bool:
	if !pawn:
		return false
	
	tree.execute( pawn, &"event_unpossessed", [self] )
	
	pawn = null
	pawn_changed.emit( pawn )
	tree.send_global_notification( &"pawn_changed", [ self, pawn ] )
	return true
