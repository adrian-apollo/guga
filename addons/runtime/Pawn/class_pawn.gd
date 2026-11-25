class_name CPawn
extends ComponentBase

@export_group("Body")
@export var collision_shape:NodePath
@export var eyes_reference:NodePath
@export var base_eye_height:float = 64.0

@export_group( "Controller" )
@export var input_enable:bool = true
@export var use_controller_rotation:bool = true
@export var use_controller_pitch:bool = false
@export var use_controller_yaw:bool = false
@export var use_controller_roll:bool = false
@export var allowed_yaw_error:float = 10.99
@export var base_turn_rate:float = 1.0
@export var base_lookup_rate:float = 1.0

@export_group("Possession")
##	Ignored if value is -1, players start at 0
@export_range(-1, 10, 1, "or_greater") var autopossess_by_player_with_index:int = -1

##	Ignored if empty
@export var autopossess_by_ai_with_class:String
@export var attach_ai_controller:bool = false
@export var internal_node:bool = true

@export_group("Debug","d_")
@export var d_simulate_input:bool = false
@export var d_movement_vector:Vector3 = Vector3.ZERO

signal s_possessed( c:Controller )
signal s_unpossessed
signal s_controller_changed( Controller )
signal s_restarted
signal s_debug

var controller:Controller
var _collision_shape:Node
var _previous_controller:Controller
var _input_vector:Vector3
var _last_received_input_vector:Vector3
var _last_consumed_input_vector:Vector3
var _player_state:PlayerState
var _last_hit_by:Controller
var _is_player_controlled:bool
var _is_ai_controlled:bool
var _height:float
var _half_height:float

var _movement_components:Array[ CMovementBase ]
var _movement_component:CMovementBase
var _player_input_component:ComponentBase
var _player_camera_manager:ComponentBase

#region	setup
func event_begin():
	setup_debug()
	_autopossess_by_player()
	_autopossess_by_ai_controller()
	_get_collision_shape_and_height()

func _get_collision_shape_and_height():
	if collision_shape.is_empty():
		return
	
	_collision_shape = owner.get_node_or_null( collision_shape )
	if !_collision_shape:
		return

	_height = _collision_shape.shape.get_rect().size.y
	_half_height = _collision_shape.shape.get_rect().get_center().y

func _autopossess_by_player():
	if autopossess_by_player_with_index < 0:
		return

	#	Autopossess by a PlayerController
	var c:PlayerController = tree.find_player_controller_with_index(
		owner,
		autopossess_by_player_with_index
		)

	if is_instance_valid( c ):
		_previous_controller = controller
		if c.possess( owner ):
			controller = c
			_is_player_controlled = true

func _autopossess_by_ai_controller():
	if is_instance_valid( controller ):
		return
	if autopossess_by_player_with_index:
		return
	if autopossess_by_ai_with_class.is_empty():
		return

	var newaic:AIController = load( autopossess_by_ai_with_class).new()
	if attach_ai_controller:
		owner.add_child( newaic, false, 1 if internal_node else 0 )
		newaic.owner = owner
	else:
		_level.add_child( newaic, false, 1 if internal_node else 0  )
		newaic.owner = _level

	_is_ai_controlled = newaic.possess( owner )

#endregion setup

func event_physics_tick( _delta:float ):
	s_debug.emit()

#region possession

func event_possessed( _controller ) -> bool:
	if !is_instance_valid( _controller ):
		return false
	if controller == _controller:
		return false
	if controller:
		_previous_controller = controller

	controller = _controller
	return true

func event_unpossessed( _controller ) -> bool:
	if !is_instance_valid( _controller ):
		return false
	if !controller:
		return false
	if controller != _controller:
		return false

	_previous_controller = controller
	
	controller = null
	return true

#endregion possession

#region public methods
func face_rotation( vector:Vector3, delta:float, use_delta:bool = false ):
	if !use_controller_rotation:
		return

	if use_controller_roll:
		owner.global_rotation.x = move_toward(
			owner.global_rotation.x,
			vector.x,
			delta if use_delta else 1
			)

	if use_controller_yaw:
		owner.global_rotation.y = move_toward(
			owner.global_rotation.y,
			vector.y,
			delta if use_delta else 1
			)

	if use_controller_pitch and owner.is_class( &"Node3D" ):
		owner.global_rotation.z = move_toward(
			owner.global_rotation.z,
			vector.z,
			delta if use_delta else 1
			)

func add_movement_input(
	direction:Vector3,
	scale:float = 1.0,
	is_force:bool = false
	):

	if _movement_component:
		_movement_component.add_input_vector( direction, scale, is_force )

func turn_off():
	if collision_shape:
		_collision_shape.set_deferred( &"set_disabled", true )
	if _movement_component:
		_movement_component.stop_movement_immediately()

#endregion

#region debug input

func setup_debug():
	if !d_simulate_input:
		return
	
	s_debug.connect( inject_input )

func inject_input():
	add_movement_input( d_movement_vector )

#endregion

func event_destroy():
	if controller:
		controller.unpossess( owner )
