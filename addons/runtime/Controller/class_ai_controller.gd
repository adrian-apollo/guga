##	Only to be instaniated by code from a pawn component

class_name AIController
extends Node

signal pawn_changed( new_pawn:Node )

var _tree:GugaTree
var _component_stack:ComponentStack = ComponentStack.new()

var pawn: Node
var destination:Vector3
var target_actor:Node
var aceptable_radius:float = 0.0
var destination_move_tolerance:float = 0.0
var filter_tag:GameTags
var allow_strafe:bool = true
var allow_partial_path:bool = true
var track_moving_goal:bool = true
var requiere_navigation_end_location:bool = true
var project_goal_location:bool = true
var reach_test_includes_agent_radius:bool = true
var reach_test_includes_goal_radius:bool = true

func _init():
	_tree = Engine.get_main_loop()
	_component_stack.owner = self

#region possession
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
	
	var pawnc:CPawn = _tree.get_component_with_method_from_actor( _pawn, &"event_unpossessed")
	if !pawnc:
		return false

	if !pawnc.event_unpossessed( self ):
		return false
	
	pawn = null
	pawn_changed.emit( _pawn )
	_tree.send_global_notification( &"pawn_changed", [ self, pawn ] )
	return true
#endregion

func move_pawn_to( _destination:Vector3 = Vector3.ZERO ):
	if !pawn:
		return

	if destination != Vector3.ZERO:
		destination = _destination
		_tree.execute( pawn, &"move_to_location", [ destination ] )

func stop_pawn_movement():
	pass
