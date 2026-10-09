class_name AIState extends Node

@export var condition:AITCondition = null
@export var tasks:Array[ AITTaskBase ]
@export var transition:Resource = null

enum RESULT{
	SUCCESS,
	FAIL
}

var p_tree:GugaTree

func _init():
	p_tree = Engine.get_main_loop()

func _ready():
	print( owner.owner )
	#	check if theres a condition and test it
	if condition:
		#	creates a one time image of that condition
		var newc:AITCondition = condition.duplicate(true)
		newc.setup( owner, self )	#	initialize the condition
		if !newc.evaulate():	#	evaluate the condition terms
			make_transition( RESULT.FAIL )	#	if not go directly to transition
			return
	
	if tasks.size()>0:
		run_next_task(tasks[0])
	make_transition(RESULT.SUCCESS)
	return
	
func run_next_task( task:AITTaskBase ):
	if !is_instance_valid( task ):
		make_transition( RESULT.SUCCESS )
	if !tasks.has( task ):
		make_transition( RESULT.SUCCESS )
	
	var t:AITTaskBase = task.duplicate(true)
	t.aitree = owner
	t.state = self
	t.original = task
	t.enter()

func make_transition(result:RESULT):
	print( result )
	return
