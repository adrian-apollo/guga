class_name AIController
extends Node

@export var components:ComponentStack

signal s_possessed( pawn:Node )
signal s_unpossessed( pawn:Node )
signal s_moving_pawn( pawn:Node )
signal s_stoping_pawn( pawn:Node )

var pawn:Node

@onready var tree:GugaTree = Engine.get_main_loop()

func possess( _pawn:Node ):
	if !is_instance_valid( _pawn ):
		return
	if _pawn == pawn:
		return

	if tree.get_component_with_method_from_actor( _pawn, &"event_possess"):
		tree.execute( _pawn, &"event_possess", [self] )
		pawn = _pawn
		s_possessed.emit( pawn )
	
func unpossess( _pawn:Node ):
	if _pawn != pawn:
		return
	tree.execute( pawn, &"event_unpossess", [self] )
	s_possessed.emit( pawn )

func move_pawn_to( position:Vector3):
	if !pawn:
		return

	tree.execute( pawn, &"move_to_position", [ position ])
	s_moving_pawn.emit( pawn )

func stop_pawn_movement():
	tree.execute( pawn, &"stop_movement", [])
	s_stoping_pawn.emit( pawn )
