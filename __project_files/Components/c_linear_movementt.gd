class_name CLinearMovement extends CMovementBase

@export var stop_on_collide:bool = false

func event_begin():
	_stop_tick()
	
func event_tick():
	if !b_can_move:
		return

	var to_target:Vector2 = target_position - owner.global_position
	var distance:float = to_target.length()
	
	if distance <= tolerance_radius:
		stop_movement()
		movement_finished.emit()
		return
	
	var direction:Vector2 = to_target / distance
	var step:float = minf( speed * owner.get_physics_process_delta_time(), distance )
	var motion:Vector2 = direction * step
	
	var collision:KinematicCollision2D = owner.move_and_collide( motion )
	if collision:
		stop_movement()

func move_to( position:Vector3, _tolerance_radius:float ):
	_reset_tick( TICK_SOURCE.PHYSICS )
	tolerance_radius = _tolerance_radius
	b_can_move = true
	target_position = Vector2( position.x, position.y )
	movement_started.emit()

func stop_movement():
	_stop_tick()
	target_position = Vector2.ZERO
	b_can_move = false
