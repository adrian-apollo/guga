class_name AIState extends Node

@export var condition:AITCondition
@export var tasks:Array[ Resource ]
@export var transition:Resource

var p_tree:GugaTree

var b_conditon_result:bool = true

func _init():
	p_tree = Engine.get_main_loop()

func _ready():
	if condition:
		b_conditon_result = condition.new()
