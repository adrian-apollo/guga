@abstract
class_name CPawnMovement extends CMovementBase

var _input_vector:Vector3
var _last_input_vector:Vector3
var _last_consumed_input_vector:Vector3
var _pawn_component:CPawn

func add_input_vector( vector:Vector3, force:bool = false ):
	pass

func get_pending_input_vector():
	pass

func consume_input_vector():
	pass

func is_move_input_ignored():
	pass