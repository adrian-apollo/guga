@abstract
class_name CMovementBase extends ComponentBase

@export_group("Main")
@export var b_can_move:bool = true
@export var speed:float = 100.0
@export var tolerance_radius:float = 0.0
@export var stop_on_collide:bool = false

signal movement_started
signal movement_finished

var target_reached:bool = false
var target_position:Vector3
var start_position:Vector3
var total_distance:float
var progress:float

@abstract func move_to( destination, tolerance_radius:float )

@abstract func stop_movement()

func _to_vector3( vector:Variant ) -> Vector3:
    if vector is Vector3:
        return vector
    
    return Vector3( vector.x, vector.y, 0)

func _to_vector2( vector:Variant ) -> Vector2:
    if vector is Vector2:
        return vector
    
    return Vector2( vector.x, vector.y )