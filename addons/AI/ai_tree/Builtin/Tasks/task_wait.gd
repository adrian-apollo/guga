class_name AITWait extends AITaskBase

@export var delay:float = 1.0

func enter( aitree: AITreeBase ):
	reference()

	await  aitree.get_tree().create_timer( delay ).timeout

	finish_task( aitree )

	unreference()
