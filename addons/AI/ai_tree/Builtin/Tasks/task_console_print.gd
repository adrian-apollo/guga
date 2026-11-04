class_name AIT_ConsolePrint extends AITaskBase

@export var text:String = "Task"

func enter( aitree: AITreeBase ):
	print( text )
	finish_task( aitree )
