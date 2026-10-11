class_name AITWait extends AITaskBase

@export var delay:float = 1.0

func enter():
	reference()
	await tree.create_timer(delay).timeout
	unreference()
	finish()
