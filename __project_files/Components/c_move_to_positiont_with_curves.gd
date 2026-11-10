class_name CMoveToPositionWithCurves extends CMovementBase

@export var curves:Array[ Curve2D ]
@export var amplitude:float
@export var wave_count:float
@export var sampler:int

func event_begin():
	_stop_tick()

func event_physics_tick( delta:float ):
	if !b_can_move:
		return

	var to_target:Vector3 = target_position - _to_vector3( owner.global_position )
	var distance:float = to_target.length()

	if distance <= tolerance_radius:
		stop_movement()
		movement_finished.emit()
		return
	
	progress = 1 - (_to_vector3( owner.global_position).distance_to( target_position ) / total_distance )

	var direction:Vector3 = to_target / distance
	var step:float = minf( speed * delta, distance )
	var motion:Vector3 = direction * step
	
	if owner is Node2D:
		var collision:KinematicCollision2D = owner.move_and_collide(
														_to_vector2( motion ))
		if collision:
			stop_movement()
		return

	var collision:KinematicCollision3D = owner.move_and_collide( motion )
	if collision:
		stop_movement()

func move_to( position:Vector3, _tolerance_radius:float ):
	_reset_tick()

	tolerance_radius = _tolerance_radius

	b_can_move = true
	
	start_position = _to_vector3( owner.global_position )
	target_position = position
	total_distance = start_position.distance_to( target_position )

	if owner is Node2D:
		owner.look_at( _to_vector2( target_position ))
	if owner is Node3D:
		owner.look_at( target_position )

	movement_started.emit()

func stop_movement():
	_stop_tick()

	b_can_move = false
	progress = 0
	target_position = Vector3.ZERO
	start_position = Vector3.ZERO

