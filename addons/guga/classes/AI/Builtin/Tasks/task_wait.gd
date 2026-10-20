class_name AITWait extends AITaskBase

@export var delay:float = 1.0

func enter_task( aitree: AITreeBase ):
	reference()
	await Engine.get_main_loop().create_timer(delay).timeout
	finish_task( aitree )
	unreference()
