class_name AIWActorProperty extends AIWatcherBase

func event_update(  aitree:AITreeBase ):
	aitree.parameters.set(
		parameter_to_update,
		aitree.pawn.get( parameter_to_update )
		)