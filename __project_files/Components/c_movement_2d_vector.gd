class_name CMovement2DVector extends CMovementBase

@export var movement_vector:Vector2
@export var stop_on_collide:bool = false

func event_physics_tick( delta:float ):
	if !b_can_move:
		return

	var collision:KinematicCollision2D = owner.move_and_collide( movement_vector * speed * delta )
	if collision:
		stop_movement()

func move_to( destination, _radius:float ):
	movement_vector = destination

func stop_movement():
	_stop_tick()
	b_can_move = false
