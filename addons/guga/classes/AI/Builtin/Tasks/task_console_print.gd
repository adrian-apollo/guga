class_name AIT_ConsolePrint extends AITaskBase

@export var text:String = "Task"

var max:int = 10
	
func update_task( aitree: AITreeBase ):
	print( text + str( max))
	max -= 1
	if max == 0:
		finish_task( aitree, AITreeBase.STATE_RESULT.SUCCESS )
