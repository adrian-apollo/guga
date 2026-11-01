class_name CVectorConstantMovement2D extends ComponentBase

@export var movement_vector:Vector2
@export var speed:float = 100.0
@export var stop_on_collide:bool = false

var is_moving:bool = true

func event_tick():
	if !is_moving:
		return
	var collision:KinematicCollision2D = owner.move_and_collide( movement_vector * speed * owner.get_physics_process_delta_time() )
	if collision:
		is_moving = false
