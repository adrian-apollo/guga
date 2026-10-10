@abstract
class_name AITransition
extends Resource

@export_group("Transition on:")
@export var tick_source:TICKSOURCE

enum TICKSOURCE {
	PHYSICS_START,
	PROCESS_START
}

var tree:GugaTree = null
var aitree:AITreeBase
var state:AIState

func _init():
	tree = Engine.get_main_loop()

func make_transition( _result:AIState.RESULT ):
	pass
