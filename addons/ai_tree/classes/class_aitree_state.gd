class_name AIState extends Node

enum BEHAVIOR{
	TRY_ENTER_STATE,
	SELECT_CHILDREN_IN_ORDER,
	SELECT_RANDOM_CHILD
}
##	This is behavior between a state and its child states.
##	Try enter = Will enter the phater state ignoring its children, default option for leafs states.
##	Select children in order = will run every state in the order they appear,used for chained behaviors.
##	Select childer in random order = will enter a random child state everytime, useful for random behavior.
@export var enter_behavior:BEHAVIOR = BEHAVIOR.TRY_ENTER_STATE

##	An array of conditons, everyone must be true to run tasks, will fail if at least one is false.
@export var condition:Array[ AITCondition ] = []

##	An array of task to complete. If a task fails to complete the state will not be completed thus failed.
@export var tasks:Array[ AITaskBase ]

##	Transitions selectable depending of the state result, SUCCESS or FAIL.
##	At least one should be added to give continuity to the execution of states.
@export var transitions:Array [ AITransition ]

@onready var children:Array[ Node ] = get_children()

var b_is_leaf_state:bool = true

func _ready():
	if children.size() >= 1:
		b_is_leaf_state = false
