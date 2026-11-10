class_name AIWSaveInitialPosition extends AIWatcherBase

func event_begin( _aitree:AITreeBase ):
	if is_instance_valid( _aitree.pawn ):
		var location:Vector3 = Vector3.ZERO

		if _aitree.pawn is Node2D:
			var pawn:Node2D = _aitree.pawn
			location = Vector3( pawn.global_position.x, pawn.position.y, 0)

		if _aitree.pawn is Node3D:
			var pawn:Node3D = _aitree.pawn
			location = pawn.position
		
		_aitree.const_parameters[ parameter_to_update ] = location