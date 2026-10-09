@abstract
class_name AITCondition
extends Resource

var tree:GugaTree
var aitree:AITreeBase
var aistate:AIState

func _init():
	tree = Engine.get_main_loop()

func setup(_aitree:AITreeBase, _state:AIState):
	aitree = _aitree
	aistate = _state

func evaulate() -> bool:
	return true
