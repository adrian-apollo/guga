class_name AIT_ConsolePrint extends AITaskBase

@export var text:String = "Task"

func update( aitree: AITreeBase ):
	print( text )
	exit( aitree )
