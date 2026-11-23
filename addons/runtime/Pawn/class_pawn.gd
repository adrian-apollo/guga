class_name CPawn
extends ComponentBase

@export_group( "Pawn" )
@export var use_controller_rotation:bool
@export var use_controller_pitch:bool = true
@export var use_controller_yaw:bool = true
@export var use_controller_roll:bool = true
@export var input_enable:bool = true
@export var input_component_class:String
@export var autopossess_player:bool = false
@export var autopossess_ai:bool
@export var ai_controller_class:String
@export var base_eye_height:float = 0.0

signal s_possessed( c:Controller )
signal s_unpossessed
signal s_controller_changed( Controller )
signal s_restarted

var _controller:Controller
var _previous_controller:Controller
var _input_vector:Vector3
var _last_received_input_vector:Vector3
var _last_consumed_input_vector:Vector3
var _pawn_movement_component:CMovementBase
var _player_state:PlayerState
var _last_hit_by:Controller
var _allowed_yaw_error:float
var _should_take_damage:bool
var _is_player_controlled:bool
var _is_ai_controlled:bool

func event_begin():
	var pmc:ComponentBase = tree.find_component_on_actor( owner, CMovementBase )
	if pmc:
		_pawn_movement_component = pmc

func event_possessed( controller ) -> bool:
	return false

func event_unpossessed( controller ) -> bool:
	return false

func spawn_controller():
	pass

func create_input_component():
	pass

func destroy_input_component():
	pass

func setup_input_component():
	pass

func add_movement_input( direction:Vector3, scale:float = 1.0, is_force:bool = false ):
	pass

func get_pending_movement_input_vector():
	pass

func get_last_movement_input_vector():
	pass

func get_last_consumed_movement_input_vector():
	pass

func consume_movement_input_vector():
	pass

func is_controller_ognoring_input() -> bool:
	return false

func get_input_component() -> ComponentBase:
	return null

func _add_input( location:Vector3, rotation:Vector3 ):
	#_input_data.origin = location
	#_input_data.basis = Basis.from_euler( rotation )
	pass

func _consume_input():
	pass

func _get_local_viewing_player_controller() -> Node:
	return null

func find_player_state():
	pass

func turn_off():
	pass

func pawn_start_fire( mode:int = 0):
	pass

func get_physics_body_volume():
	pass

func reached_target_rotation() -> bool:
	return false

func get_default_half_height() -> float:
	return 0.0

func get_control_rotation() -> Vector3:
	return Vector3.ZERO

func get_location_on_nav_mesh() -> Vector3:
	return Vector3.ZERO

func get_gravity_direction():
	pass

func get_gravity_vector():
	pass

func _reset_to_default_values():
	pass

func recalculate_eye_base_height():
	pass
