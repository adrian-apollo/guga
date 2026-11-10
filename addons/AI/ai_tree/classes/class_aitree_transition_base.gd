class_name AITransition extends Resource

#@export_group("Behavior")
@export var trigger:TRIGGERS = TRIGGERS.GO_TO_NEXT_STATE
@export var conditions:Array[ AITCondition ] = []
@export var go_to_state:NodePath

enum TRIGGERS {
	ON_STATE_COMPLETED,
	ON_STATE_FAILED,
	GO_TO_NEXT_STATE
}

var tree:GugaTree

func _init() -> void:
	tree = Engine.get_main_loop()

func make_transition( aitree:AITreeBase ):
	if trigger == TRIGGERS.GO_TO_NEXT_STATE:
		if !_evualte_conditons( aitree ):
			return
		var nodes:Array[ Node ] = tree.get_inbeetwen_nodes(
			aitree,
			aitree.current_state,
			true,
			false )
		var parent:Node = nodes.pop_back()
		if parent.get_child_count() == 1:
			return
		var index:int = parent.find_child( aitree.current_state.name ).get_index()
		if index + 1 == parent.get_child_count():
			return
		
		aitree._changet_to_state( parent.get_child( index + 1) )
		return

	if trigger == TRIGGERS.ON_STATE_COMPLETED && aitree.current_state._state_result == AIState.STATE_RESULT.SUCCESS:
		if !_evualte_conditons( aitree ):
			return
		_change_state( aitree, go_to_state )
		return

	if trigger == TRIGGERS.ON_STATE_FAILED && aitree.current_state._state_result == AIState.STATE_RESULT.FAILED:
		if !_evualte_conditons( aitree ):
			return
		_change_state( aitree, go_to_state )
		return

func _evualte_conditons( aitree:AITreeBase ) -> bool:
	for c in conditions:
		if !c.evaulate( aitree, aitree.current_state ):
			return	false

	return true

func _change_state( aitree:AITreeBase, path:NodePath ):
	var next_state:AIState = aitree.current_state.get_node_or_null( path )
	if !next_state:
		aitree._changet_to_state( aitree.initial_state )
		return
	aitree._changet_to_state( next_state )
