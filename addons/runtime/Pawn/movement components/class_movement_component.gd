#@abstract
class_name CMovementBase extends ComponentBase

#region exports
@export_group("Main")
@export var updated_body:NodePath
@export var collision_shape:NodePath
@export var prefered_movement_method:MovementMethod

@export_group("Variables")
@export var can_move:bool = true
@export var max_speed:float = 100
@export var acceleration:float = 10.0
@export var aceleration_curve:Curve
@export var friction_curve:Curve
@export var friction:float
@export var snap_length:float

@export_group("Gravity")
@export var is_gravity_enabled:bool = true
@export var gravity:float = 9.8
@export var gravity_scale:float = 1.0

@export_group("Others")
@export var stop_on_collide:bool = false
@export var constrain_to_plane:bool = false
@export var constrained_axis_movement:Vector3 = Vector3( 1, 1, 1)

@export_group("Debug")
@export var debug_simulated_source:DebugInputSource
@export var debug_input_vector:Vector3 = Vector3( 1, 0, 0)
#endregion exports

#region signals
signal s_do_movement
signal s_debug
signal s_perform_move
#endregion signals

#region private variables
var _updated_body:Node
var _collision_shape
var _control_input_vector:Vector3 = Vector3.ZERO
var _velocity: Vector3 = Vector3.ZERO
var _body_class:UpdatedBodyClass
var _actor_dimension:ActorDimension
var _delta:float
var _available_movement_methods:Array[ MovementMethod ]
#endregion private variables

#region begin
func event_begin():
	_get_updated_body_and_collision_shape()
	if !_updated_body:
		tree.new_log_message( self, "No body found", tree.LogMessageMode.ERROR )
		_destructor()
		return

	_find_updated_body_class()
	_find_dimension()
	if _actor_dimension == ActorDimension.OTHER:
		tree.new_log_message( self, "Body is not movable", tree.LogMessageMode.ERROR )
		_destructor()
		return

	_find_available_movement_methods()
	_debug_setup()
	_connect_movement_action()

#endregion begin

#region ticks
func event_physics_tick( delta:float ):
	if !can_move:
		return
	_delta = delta
	s_debug.emit()

	_phys_movement( _consume_input_vector() )
	s_perform_move.emit()

#endregion ticks

#region public methods
func add_input_vector( direction: Vector3, scale_value: float = 1.0, _force: bool = false):
	_control_input_vector += direction.normalized() * scale_value

func request_direct_move(_move_velocity: Vector3, _force_max_speed: bool = false):
	# Esqueleto: inyecta velocidad calculada por un algoritmo de navegación directamente.
	_velocity = _move_velocity

func stop_movement_immediately():
	_stop_tick()
	
	can_move = false

	_velocity = Vector3.ZERO

	if owner.has_method(&"velocity"):
		if _actor_dimension == ActorDimension.NODE2D:
			owner.set( &"velocity", Vector2.ZERO )
		if _actor_dimension == ActorDimension.NODE3D:
			owner.set( &"velocity", Vector3.ZERO )

#endregion public methods

#region private methods

#region setup
func _find_available_movement_methods():
	if _updated_body.is_class( &"Node2D" ) or _updated_body.is_class( &"Node3D" ):
		_available_movement_methods.push_back( MovementMethod.DIRECT_TRANSFORM )
	if _updated_body.is_class( &"PhysicsBody2D") or _updated_body.is_class( &"PhysicsBody3D"):
		_available_movement_methods.push_back( MovementMethod.MOVE_AND_COLLIDE )
	if _updated_body.is_class( &"CharacterBody2D" ) or _updated_body.is_class( &"CharacterBody3D" ):
		_available_movement_methods.push_back( MovementMethod.MOVE_AND_SLIDE )

func _connect_movement_action():
	match prefered_movement_method:
		MovementMethod.DIRECT_TRANSFORM:
			if _available_movement_methods.has( MovementMethod.DIRECT_TRANSFORM ):
				s_perform_move.connect( _perform_move )
				return

		MovementMethod.MOVE_AND_COLLIDE:
			if _available_movement_methods.has( MovementMethod.MOVE_AND_COLLIDE ):
				s_perform_move.connect( _perform_move_physics_body )
				return

		MovementMethod.MOVE_AND_SLIDE:
			if _available_movement_methods.has( MovementMethod.MOVE_AND_SLIDE ):
				s_perform_move.connect( _perform_move_character )
				return

	GameplayStatics.new_log_message(
		self,
		"No match for prefered movement method: " + str( prefered_movement_method ),
		GameplayStatics.LogMessageMode.ERROR
		)
	
	_destructor()

func _find_dimension():
	if _updated_body.is_class(&"Node2D"):
		_actor_dimension = ActorDimension.NODE2D
		return

	if _updated_body.is_class(&"Node3D"):
		_actor_dimension = ActorDimension.NODE3D
		return

	_actor_dimension = ActorDimension.OTHER

func _find_updated_body_class():
	if _updated_body.is_class( &"CharacterBody2D" ) or _updated_body.is_class( &"CharacterBody3D" ):
		_body_class = UpdatedBodyClass.CHARACTER
		return
	
	if _updated_body.is_class( &"PhysicsBody2D") or _updated_body.is_class( &"PhysicsBody3D"):
		_body_class = UpdatedBodyClass.PHYSICS_BODY
		return
	
	_body_class = UpdatedBodyClass.OTHER
	
func _get_updated_body_and_collision_shape():
	if updated_body.is_empty():
		_updated_body = owner
		return
	
	_updated_body = owner.get_node_or_null( updated_body )

	if !is_instance_valid( _updated_body ):
		return
	_collision_shape = owner.get_node_or_null( collision_shape )

#endregion setup

#region	movement

func _consume_input_vector() -> Vector3:
	var input_this_frame:Vector3 = _control_input_vector
	_control_input_vector = Vector3.ZERO
	
	return input_this_frame.limit_length(1.0)

## Procesa la simulación de inercia, aceleración y desaceleración.
func _phys_movement( _input: Vector3 ):
	if _updated_body == null:
		return

	var horizontal_vel:Vector3 = Vector3( _velocity.x, 0.0, _velocity.z )
	var vertical_vel:Vector3 = Vector3( 0.0, _velocity.y, 0.0 )

	# 2. Asegurarse de que el input solo afecte al plano horizontal
	var move_dir:Vector3 = Vector3( _input.x, 0.0, _input.z )

	# 3. Simulación física horizontal (Aceleración vs Fricción estilo UE5)
	if move_dir.length_squared() > 0.001:
		var target_horizontal:Vector3 = move_dir * max_speed
		horizontal_vel = horizontal_vel.move_toward( target_horizontal, acceleration )
	else:
		horizontal_vel = horizontal_vel.move_toward( Vector3.ZERO, friction )

	# 4. Simulación física vertical (Gravedad)
	if is_gravity_enabled:
		vertical_vel.y -= (
			gravity if _actor_dimension == ActorDimension.NODE3D
			else -gravity
		) * gravity_scale

	# 5. Reconstruir el vector de velocidad consolidado
	_velocity = horizontal_vel + vertical_vel

func _perform_move():
	_updated_body.global_position += (
		_velocity
		if _actor_dimension == ActorDimension.NODE3D
		else tree.to_vector2( _velocity )
	) * _delta

## Realiza el movimiento en el mundo llamando a move_and_collide o move_and_slide.
func _perform_move_physics_body():
	_updated_body.move_and_collide((
		_velocity
		if _actor_dimension == ActorDimension.NODE3D
		else
			tree.to_vector2( _velocity )
		)*_delta)

## Realiza el movimiento en el mundo llamando a move_and_collide o move_and_slide.
func _perform_move_character():
	if updated_body == null:
		return

	# 1. Transferir la velocidad calculada al cuerpo físico cinemático
	_updated_body.velocity = _velocity if _actor_dimension == ActorDimension.NODE3D else tree.to_vector2( _velocity )
	_updated_body.velocity = _updated_body.velocity
	# 2. Configurar el comportamiento de escalones y adherencia al piso (Floor Snap)
	# Si vamos cayendo o estamos en el suelo, permitimos que se adhiera a desniveles.
	# Si vamos subiendo (ej: salto), deshabilitamos el snap para despegar libremente.
	if _velocity.y <= 0.0:
		_updated_body.floor_snap_length = snap_length
	else:
		_updated_body.floor_snap_length = 0.0

	# 3. Resolver colisiones físicas contra el entorno.
	# En Godot 4, move_and_slide() utiliza automáticamente updated_body.velocity,
	# resuelve deslices en rampas y detecta colisiones con paredes/suelos.
	_updated_body.move_and_slide()

	# 4. RECUPERAR la velocidad real modificada por los impactos.
	# Esto es fundamental: si chocamos de frente contra un muro, move_and_slide()
	# anulará esa parte del vector. Si no actualizamos 'velocity' con el valor real
	# del cuerpo, el componente intentaría seguir empujando contra la pared con inercia fantasma.
	_velocity = tree.to_vector3( _updated_body.velocity )

#endregion movement

#region debug
func _debug_setup():
	match debug_simulated_source:
		DebugInputSource.DISABLED:
			return
		DebugInputSource.SIMULATE_PLAYER:
			s_debug.connect( _debug_player_input )
		DebugInputSource.SIMULATE_AI:
			s_debug.connect( _debug_ai_input )

func _debug_player_input():
	add_input_vector( debug_input_vector )

func _debug_ai_input():
	request_direct_move( debug_input_vector )
#endregion

#endregion private methods

#region enums
enum MovementMethod{
	DIRECT_TRANSFORM,
	MOVE_AND_COLLIDE,
	MOVE_AND_SLIDE
}

enum DebugInputSource{
	DISABLED,
	SIMULATE_PLAYER,
	SIMULATE_AI
}

enum UpdatedBodyClass{
	OTHER, #	to be moved by changing the location aka teleporting
	PHYSICS_BODY, #	moved with move&collide
	CHARACTER	#	moved with move&collide or move&slide
}

enum ActorDimension{
	OTHER,
	NODE2D,
	NODE3D
}
#endregion enums
