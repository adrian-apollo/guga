class_name AITCActorIsInVisionRange extends AITCondition

@export var target_parameter:StringName = &"player"
@export_range(0.0, 50000.0, 1.0) var vision_range:float = 300.0
@export_range( 0.0, 360.0, 1, "degrees") var vision_anlge:float = 90.0

func evaulate( aitree:AITreeBase, _state:AIState ) -> bool:
    if !aitree.parameters.get( target_parameter ):
        return false
    
    var target:Node2D = aitree.parameters.get( target_parameter )
    var pawn2d:Node2D = aitree.pawn

    var to_target:Vector2 = target.global_position - aitree.pawn.global_position
    var distance:float = to_target.length()

    if distance > vision_range:
        return false

    var forward:Vector2 = pawn2d.global_transform.y.normalized()
    var direction_to_target:Vector2 = to_target.normalized()

    var angle:float = abs( forward.angle_to( direction_to_target ))

    if angle > deg_to_rad( vision_anlge / 2.0 ):
        return false

    return true