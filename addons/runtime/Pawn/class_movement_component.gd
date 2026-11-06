@abstract
class_name CMovementBase extends ComponentBase

@export var b_can_move:bool = true
@export var speed:float = 100.0
@export var tolerance_radius:float = 0.0

signal movement_started
signal movement_finished

var target_reached:bool = false
var target_position:Vector2 = Vector2.ZERO

@abstract func move_to( destination, tolerance_radius:float )

@abstract func stop_movement()
