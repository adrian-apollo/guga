@abstract
class_name AITElement extends Resource

enum COMPARE {
	EQUAL,
	GREATER,
	LESS
}

enum RESULT{
	SUCCESS,
	FAIL
}

enum TICKSOURCE {
	PHYSICS_START,
	PROCESS_START
}

var tree:GugaTree
var actor:Node
var aitree:AITreeBase
var state:AIState

func _init():
	tree = Engine.get_main_loop()

func setup( _aitree:AITreeBase, _state:AIState):
	aitree = _aitree
	state = _state
	actor = aitree.owner
