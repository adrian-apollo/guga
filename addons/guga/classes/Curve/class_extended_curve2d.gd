class_name ExtendedCurve2D extends Curve2D

signal movement_completed

var _original_vector:Vector2
var _original_length:float
var _original_angle:float

var _point_start:Vector2
var _point_end:Vector2
var _target_vector:Vector2
var _target_length:float
var _calculated_scale:float
var _target_angle:float

var _last_position:Vector2
var _first_position:Vector2

var progress:float = 0.0
var direction:float = 1.0

#region public methods

func fit_to_points( start:Vector2, end:Vector2 ) -> void:
	if point_count == 0:
		return

	_original_vector = get_point_position( 0 ) - get_point_position( point_count -1)
	_original_length = _original_vector.length()
	_original_angle = _original_vector.angle()

	_point_start = start
	_point_end = end
	_target_vector = _point_start - _point_end
	_target_length = _target_vector.length()
	_calculated_scale = _target_length / _original_length
	_target_angle = _target_vector.angle()

	_update_shape()
	_last_position  = get_point_position( point_count - 1)
	_first_position = get_point_position( 0 )

func loop_ping_pong( amount:float ) -> Transform2D:
	progress += amount * direction
	var current_position:Vector2 = sample_baked( progress )
	if is_zero_approx( current_position.distance_squared_to( _last_position )):
		direction = -1
		movement_completed.emit()
	if is_zero_approx( current_position.distance_squared_to( _first_position )):
		direction = 1

	return sample_baked_with_rotation( progress )

func loop_projectile( amount:float )  -> Transform2D:
	progress += amount * direction
	var current_position:Vector2 = sample_baked( progress )
	if is_zero_approx( current_position.distance_squared_to( _last_position )):
		progress = 0

	return sample_baked_with_rotation( progress )

#func
##	Usage:
##	func _physics_process(_delta: float) -> void:
##	runtime_curve.update_character_body_2d( self, runtime_curve.loop_ping_pong( speed * _delta ), speed)
##	move_and_slide()
func update_character_body_2d(
	character2d:CharacterBody2D,
	curve_transform:Transform2D,
	speed:float ):

	var dir:Vector2 = ( curve_transform.origin - character2d.global_position ).normalized()
	character2d.velocity = dir * speed
	character2d.rotation = curve_transform.get_rotation()

##	Usage:
##	func _physics_process(_delta: float) -> void:
##	var motion:Vector2 = runtime_curve.update_physics_body_2d( self, runtime_curve.loop_ping_pong( speed * _delta ))
##	move_and_collide( motion )
func update_physics_body_2d(
	character2d:PhysicsBody2D,
	curve_transform:Transform2D,
	) -> Vector2:

	var to_target: Vector2 = curve_transform.get_origin() - character2d.global_position
	var distance: float = to_target.length()

	var dir: Vector2 = to_target / distance
	var motion: Vector2 = dir * distance
	
	character2d.rotation = curve_transform.get_rotation()
	
	return motion

func mirror( x:bool = false, y:bool=false ):
	for p in range( get_point_count()  ):
		var point:Vector2 = get_point_position( p )
		if x:
			set_point_position( p, point * Vector2( -1, 1 ))
		if y:
			set_point_position( p, point * Vector2( 1, -1 ))

#endregion public methods

#region private methods

func _update_shape():
	_rotate()
	_scale()
	_move()

func _scale():
	for p in point_count:
		set_point_position( p, get_point_position( p ) * _calculated_scale )
		set_point_in( p, get_point_in( p ) * _calculated_scale )
		set_point_out( p, get_point_out( p ) * _calculated_scale )

func _rotate():
	var angle_delta: float = _target_angle - _original_angle

	for p in range( get_point_count() ):
		var point:Vector2 = get_point_position( p )
		var rotated_pos: Vector2 = point.rotated( angle_delta )

		set_point_position( p, rotated_pos)
		set_point_in( p, get_point_in(p).rotated( angle_delta ))
		set_point_out( p, get_point_out(p).rotated( angle_delta ))

func _move():
	for p in point_count:
		set_point_position( p, get_point_position( p ) + _point_start )

#endregion
