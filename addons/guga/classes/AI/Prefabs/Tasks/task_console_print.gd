class_name AITConsolePrint extends AITaskBase

@export var text:String = "Task"

func enter():
	print(text)
	finish()
