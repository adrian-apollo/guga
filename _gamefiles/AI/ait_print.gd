class_name AITPrint extends AITaskBase

@export var text:String = "Task"

func enter():
	print(text)
	finish()
