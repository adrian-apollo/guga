@abstract
class_name AITCondition
extends Resource

var tree:GugaTree
var aitree:AITreeBase
var aistate:AIState

func _init( _aitree:AITreeBase, _aistate:AIState ):
	tree = Engine.get_main_loop()
	aitree = _aitree
	aistate = _aistate

func evaulate() -> bool:
	return true
