class_name AIT_ConsolePrint extends AITaskBase

@export var text:String = "Task"
@export var finish:bool = true

func enter( aitree: AITreeBase ):
	print( text )
	
	if !finish:
		return

	finish_task( aitree )

func tick( aitree: AITreeBase ):
	print( text )
