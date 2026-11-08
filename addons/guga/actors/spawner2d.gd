class_name Spawner2D
extends Marker2D

@export_range( 0, 100, 1, "or_greater" ) var quantity:int = 0
@export_file(".tscn") var scene:String
@export_range(0, 1, 0.01, "or_greater") var delay:float = 0
@export_range(0, 100, 0.00001,"or_greater" ) var spawn_interval:float = 1
@export var under_node:Node
@export var autodestroy:bool = true
@export var transport:bool = true
@export var spawn_enabled:bool

signal s_started
signal s_spawned( Node )
signal s_completed
signal s_stoped
signal s_destroyed

var _tree:GugaTree
var _amount:int = 0
var can_fire:bool
var _level:Level

func _init():
	_tree = Engine.get_main_loop()

func _ready():
	_level = _tree.find_owning_level( self )
	await _tree.create_timer( delay, false, false, false).timeout
	_level.connect_callable_to_timer( _spawn, spawn_interval )
	s_started.emit()
	
	if !under_node:
		under_node = _tree.current_level
	
	can_fire = spawn_enabled

func stop():
	_level.disconnect_callable_from_timer( _spawn, spawn_interval )
	s_stoped.emit()

func trigger( ):
	can_fire = true

func _spawn():
	if !can_fire:
		return

	if !ResourceLoader.exists( scene ):
		completed()

	var newnode:Node2D = load(scene).instantiate()
	under_node.add_child( newnode )
	newnode.owner = under_node
	
	if transport:
		newnode.global_position = global_position
	
	_amount += 1
	
	if quantity and _amount == quantity:
		completed()
	
	s_spawned.emit( newnode )
	
	can_fire = spawn_enabled

func completed():
	s_completed.emit()
	stop()
	if autodestroy:
		queue_free()
		s_destroyed.emit()
