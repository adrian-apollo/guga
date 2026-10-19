class_name AIState extends Node

@export var condition:Array[ AITCondition ] = []
@export var tasks:Array[ AITaskBase ]
@export var transition:Array [ AITransition ]

func evaluate( aitree:AITreeBase ) -> bool:
	return true
