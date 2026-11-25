##	Only to be instaniated by code from a pawn component
class_name AIController
extends Controller

var _component_stack:ComponentStack = ComponentStack.new()

var destination:Vector3 = Vector3.ZERO
var target_actor:Node
var aceptable_radius:float = 0.0
var destination_move_tolerance:float = 0.0
#var filter_tag:GameTags
var allow_strafe:bool = true
var allow_partial_path:bool = true
var track_moving_goal:bool = true
var requiere_navigation_end_location:bool = true
var project_goal_location:bool = true
var reach_test_includes_agent_radius:bool = true
var reach_test_includes_goal_radius:bool = true
var pawn_is_moving:bool = false