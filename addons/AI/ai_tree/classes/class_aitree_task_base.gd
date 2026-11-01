@abstract
class_name AITaskBase extends Resource

var b_entered:bool = false
var b_completed:bool = false

enum RESULT{
	SUCCEDED,
	FAILED
}

func enter( aitree: AITreeBase ):
	pass

func update( aitree: AITreeBase ):
	pass

func exit( aitree: AITreeBase, result:RESULT = RESULT.SUCCEDED):
	b_completed = true
	if result == RESULT.FAILED:
		aitree.result = aitree.RESULT.FAILED
