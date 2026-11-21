##	Only to be instaniated by code from a pawn component
class_name AIController
extends Controller

var _component_stack:ComponentStack = ComponentStack.new()

var destination:Vector3 = Vector3.ZERO
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
var pawn_is_moving:bool = false
@onready var mc:CMovementBase = _tree.get_component_with_method_from_actor( pawn, &"move_to")

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
	mc = _tree.get_component_with_method_from_actor( pawn, &"move_to")
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
	mc = null
	pawn_changed.emit( _pawn )
	_tree.send_global_notification( &"pawn_changed", [ self, pawn ] )
	return true
#endregion

func move_pawn_to_destination( _destination:Vector3, _aceptable_radius:float = 0.0 ):
	if !pawn and !mc:
		return

	destination = _destination
	aceptable_radius = _aceptable_radius
	
	var to_target:Vector3
	if pawn is Node2D:
		to_target = destination - Vector3( pawn.global_position.x, pawn.global_position.y, 0 )
	else:
		to_target = destination - pawn.global_position
	var distance:float = to_target.length()
	if distance <= aceptable_radius:
		return

	mc.movement_finished.connect( movement_is_completed, 4 )
	mc.move_to( destination, _aceptable_radius )
	aceptable_radius = _aceptable_radius
	pawn_is_moving = true

func movement_is_completed():
	pawn_is_moving = false

func move_pawn_to_actor( _target_actor:Node, _aceptable_radius:float = 0.0 ):
	target_actor = _target_actor
	aceptable_radius = _aceptable_radius
	
func stop_pawn_movement():
	_tree.execute( pawn, &"stop_movement", [ false ] )
	
