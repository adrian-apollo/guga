class_name AIState extends Node

@export var condition:AITCondition = null
@export var tasks:Array[ AITaskBase ]
@export var transition:AITransition = null

enum RESULT{
	SUCCESS,
	FAIL
}

var p_tree:GugaTree

func _init():
	p_tree = Engine.get_main_loop()

func start():
	#	check if theres a condition and test it
	if condition:
		#	creates a one time image of that condition
		var newc:AITCondition = condition.duplicate(true)
		newc.setup( owner, self )	#	initialize the condition
		if !newc.evaulate():	#	evaluate the condition terms
			make_transition( RESULT.FAIL )	#	if not go directly to transition
			return
	
	run_next_task( 0 )

func run_next_task( index:int ):
	if !tasks.size() > index:
		make_transition( RESULT.SUCCESS )
		return
	if !is_instance_valid( tasks.get(index) ):
		make_transition( RESULT.SUCCESS )
		return

	_duplicate_task( tasks[index] ).enter()

func _duplicate_task(task:AITaskBase) -> AITaskBase:
	var t:AITaskBase = task.duplicate(true)
	t.aitree = owner
	t.state = self
	t.original = task
	return t

func make_transition( result:RESULT ):
	if !transition:
		return
	var t:AITransition = transition.duplicate(true)
	t.aitree = owner
	t.state = self
	t.make_transition( result )
