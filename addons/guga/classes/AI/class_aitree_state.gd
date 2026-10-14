class_name AIState extends Node

@export var condition:AITCondition = null
@export var tasks:Array[ AITaskBase ]
@export var transition:AITransition = null

var tree:GugaTree

func _init():
	tree = Engine.get_main_loop()

func start():
	#	check if theres a condition and test it
	if condition:
		#	creates a one time image of that condition
		var newc:AITCondition = condition.duplicate(true)
		newc.setup( owner, self )	#	initialize the condition
		if !newc.evaulate():	#	evaluate the condition terms
			make_transition( AITElement.RESULT.FAIL )	#	if not go directly to transition
			return
	
	run_next_task( 0 )

func run_next_task( index:int ):
	if !tasks.size() > index:
		make_transition( AITElement.RESULT.SUCCESS )
		return
	if !is_instance_valid( tasks.get(index) ):
		make_transition( AITElement.RESULT.SUCCESS )
		return

	_duplicate_task( tasks[index] ).enter()

func make_transition( result:AITElement.RESULT ):
	if !transition:
		owner.get_tree().physics_frame.connect( owner.enter_first_state, 4 )
		#owner.call_deferred(&"enter_first_state")
		return
	var t:AITransition = transition.duplicate(true)
	t.setup( owner, self)
	t.make_transition( result )

func _duplicate_task(task:AITaskBase) -> AITaskBase:
	var t:AITaskBase = task.duplicate(true)
	t.setup( owner, self)
	t.original = task
	return t
