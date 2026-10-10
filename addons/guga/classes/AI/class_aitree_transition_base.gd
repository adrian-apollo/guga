@abstract
class_name AITransition
extends Resource

var tree:GugaTree = null
var aitree:AITreeBase
var state:AIState

func _init():
	tree = Engine.get_main_loop()

func make_transition( _result:AIState.RESULT ):
	pass
