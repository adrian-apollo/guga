class_name AITransition extends Resource

#@export_group("Behavior")
@export var trigger:TRIGGERS = TRIGGERS.ON_STATE_COMPLETED
@export var conditions:Array[ AITCondition ] = []
@export var go_to_state:NodePath

enum TRIGGERS {
	ON_STATE_COMPLETED,
	ON_STATE_FAILED
}

var tree:GugaTree

func _init() -> void:
	tree = Engine.get_main_loop()

func make_transition( aitree:AITreeBase ):
	if trigger == TRIGGERS.ON_STATE_COMPLETED && aitree.current_state._state_result == AIState.STATE_RESULT.SUCCESS:
		evualte_conditons( aitree )
	
	if trigger == TRIGGERS.ON_STATE_FAILED && aitree.current_state._state_result == AIState.STATE_RESULT.FAILED:
		evualte_conditons( aitree )

func evualte_conditons( aitree:AITreeBase ):
	for c in conditions:
		if !c.evaulate( aitree, aitree.current_state ):
			break
			return

	var next_state:AIState = aitree.current_state.get_node_or_null( go_to_state )
	if !next_state:
		aitree._changet_to_state( aitree.initial_state )
	aitree._changet_to_state( next_state )
