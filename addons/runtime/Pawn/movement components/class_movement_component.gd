@abstract
class_name CMovementBase extends ComponentBase

@export_group("Main")
@export var updated_body:NodePath
@export var collision_shape:NodePath

@export_group("Variables")
@export var b_can_move:bool = true
@export var speed:float = 100.0
@export var aceleration:float = 10.0
@export var speed_curve:Curve2D
@export var max_speed:float = 1000

@export_group("Gravity")
@export var gravity_vector:Vector3 = Vector3( 0, 1, 0)
@export var gravity:float = 9.8
@export var gravity_scale:float = 1.0

@export_group("Others")
@export var stop_on_collide:bool = false
@export var constrain_to_plane:bool = false
@export var constrained_axis_movement:Vector3 = Vector3( 1, 1, 1)

signal movement_started
signal movement_finished

var target_reached:bool = false
var target_position:Vector3
var start_position:Vector3
var total_distance:float
var progress:float
var _updated_body:Node
var _collision_shape:Node
var _is_in_water:bool
var _is_on_ground:bool
var _is_on_air:bool

func _to_vector3( vector:Variant ) -> Vector3:
	if vector is Vector3:
		return vector
	
	return Vector3( vector.x, vector.y, 0)

func _to_vector2( vector:Variant ) -> Vector2:
	if vector is Vector2:
		return vector
	
	return Vector2( vector.x, vector.y )

func is_above_max_speed() -> bool:
	return false

func stop_any_movement():
	pass

func overlap_test( location:Vector3, rotation:Vector3, ignored_actors:Array[Node]) -> bool:
	return false

func move_update():
	pass