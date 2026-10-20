class_name TGoToState extends AITransition

@export var on:AITreeBase.STATE_RESULT = AITreeBase.STATE_RESULT.SUCCESS
@export var go_to:NodePath

var tree:GugaTree

func _init() -> void:
	tree = Engine.get_main_loop()

func make_transition( aitree:AITreeBase ):
	var next_state:AIState = tree.get_node_from_nodepath( aitree, go_to )
	if next_state:
		aitree.current_state = next_state
	return
