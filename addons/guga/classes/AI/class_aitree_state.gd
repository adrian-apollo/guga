class_name AIState extends Node

@export var condition:AITCondition = null
@export var tasks:Array[ Resource ] = []
@export var transition:Resource = null

var p_tree:GugaTree

func _init():
	p_tree = Engine.get_main_loop()

func _ready():
	if condition:
		var newc:AITCondition = condition.duplicate(true)
		newc.setup(owner,self)
		newc.evaulate()
		
