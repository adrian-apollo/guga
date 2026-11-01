class_name CLinearFloatingMovement2D extends ComponentBase

## sfsdfsfd

@export var speed:float = 100.0
@export var tolerance:float = 1
@export var stop_on_collide:bool = false

signal movement_started
signal movement_finished

var target_position:Vector2 = Vector2.ZERO
var is_moving:bool = false

func event_tick():
	if !is_moving:
		return
	var to_target:Vector2 = target_position - owner.global_position
	var distance:float = to_target.length()
	
	if distance <= tolerance:
		owner.global_position = target_position
		is_moving = false
		movement_finished.emit()
		return
	
	var direction:Vector2 = to_target / distance
	var step:float = minf( speed * owner.get_physics_process_delta_time(), distance )
	var motion:Vector2 = direction * step
	
	if !stop_on_collide:
		return
	var collision:KinematicCollision2D = owner.move_and_collide( motion )
	if collision:
		is_moving = false

func move_to_position( position:Vector2 ):
	movement_started.emit()
	is_moving =true
	target_position = position

func stop_movement():
	target_position = Vector2.ZERO
	is_moving = false
