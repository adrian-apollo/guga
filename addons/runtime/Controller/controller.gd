@abstract
class_name Controller
extends Node

signal pawn_changed( new_pawn:Node )

var _tree:GugaTree

var pawn: Node
var previous_pawn:Node

var control_rotation:Vector3

func _init():
	_tree = Engine.get_main_loop()

func possess( new_pawn: Node ) -> bool:
	if !is_instance_valid( new_pawn ):
			return false
	if new_pawn == pawn:
		return false

	unpossess( pawn )
		
	var pawnc:CPawn = _tree.get_component_with_method_from_actor( new_pawn, &"event_possessed")
	if !pawnc:
		return false

	if !pawnc.event_possessed( self ):
		return false

	pawn = new_pawn
	pawn_changed.emit( pawn )
	_tree.send_global_notification( &"pawn_changed", [ self, pawn] )
	return true
	
func unpossess( _pawn:Node ) -> bool:
	if !pawn:
		return false
	if !_pawn:
		return false
	
	previous_pawn = pawn
	var pawnc:CPawn = _tree.get_component_with_method_from_actor( _pawn, &"event_unpossessed")
	if !pawnc:
		return false

	if !pawnc.event_unpossessed( self ):
		return false
	
	pawn = null
	pawn_changed.emit( _pawn )
	_tree.send_global_notification( &"pawn_changed", [ self, pawn ] )
	return true

func add_roll_input( x:float):
	control_rotation.x += x

func add_yaw_input( y:float):
	control_rotation.y += y

func add_pitch_input( z:float):
	control_rotation.z += z