@abstract
class_name AITTaskBase
extends Resource

var aitree:AITreeBase
var state:AIState
var original:AITTaskBase

func enter():
	finish()

func update():
	finish()

func finish():
	#	find next task from state task list
	var next_task_index:int = state.tasks.find( original ) + 1
	#	tell state to run the next task from index
	state.run_next_task( state.run_next_task( state.tasks.get( next_task_index )))
