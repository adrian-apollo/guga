@abstract
class_name AITaskBase extends Resource

func enter_task( aitree: AITreeBase ):
	pass

func update_task( aitree: AITreeBase ):
	pass

func finish_task( aitree: AITreeBase, result:AITreeBase.STATE_RESULT ):
	aitree.change_to_next_task( result )
	
