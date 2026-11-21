class_name CMovementProjectile2D extends CMovementBase

@export var curves:Array[ ExtendedCurve2D ]

var runtime_curve:ExtendedCurve2D

func event_begin():
	tree.sanitize_array( curves )
	_stop_tick()
	
func event_physics_tick( delta:float ):
	if !b_can_move:
		return

	var motion:Vector2 = runtime_curve.update_physics_body_2d(
								owner,
								runtime_curve.loop_ping_pong( speed * delta )
							)
	owner.move_and_collide( motion )

func move_to( position:Vector3, _tolerance_radius:float ):
	_reset_tick()
	tolerance_radius = _tolerance_radius
	b_can_move = true
	target_position = position
	movement_started.emit()
	
	runtime_curve = curves.pick_random()
	
	if !runtime_curve:
		return
	
	runtime_curve.fit_to_points( owner.global_position, Vector2( position.x, position.y ))
	runtime_curve.movement_completed.connect( stop_movement )

func stop_movement():
	_stop_tick()
	target_position = Vector3.ZERO
	b_can_move = false
	movement_finished.emit()
	runtime_curve.movement_completed.disconnect( stop_movement )
