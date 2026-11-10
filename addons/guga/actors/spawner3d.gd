class_name Spawner3D extends Node3D

@export_range( 1, 100, 1, "or_greater" ) var quantity:int = 1
@export_file(".tscn") var scene:String
@export_range(0, 1, 0.01, "or_greater") var delay:float = 0
@export var autostart:bool = false
@export_range(0, 100, 0.00001,"or_greater" ) var spawn_interval:float = 1
@export var under_node:Node
@export var autodestroy:bool = true
@export var transport:bool = true

signal s_started
signal s_spawned( Node )
signal s_completed
signal s_stoped
signal s_destroyed

var _tree:GugaTree
var _amount:int = 0

func _init():
	_tree = Engine.get_main_loop()

func _ready():
	if autostart:
		start()

func start():
	await _tree.create_timer( delay, false, false, false).timeout
	_tree.connect_callable_to_timer( _tree.find_owning_level( self ),_spawn, spawn_interval )
	s_started.emit()

func stop():
	_tree.disconnect_callable_from_timer( _spawn, spawn_interval )
	s_stoped.emit()

func _spawn():
	if !ResourceLoader.exists( scene ):
		completed()

	var newnode:Node3D = load(scene).instantiate()
	under_node.add_child( newnode )
	newnode.owner = under_node
	
	if transport:
		newnode.global_position = global_position

	_amount += 1
	s_spawned.emit( newnode )
	
	if _amount == quantity:
		completed()
	
func completed():
	s_completed.emit()
	stop()
	if autodestroy:
		queue_free()
		s_destroyed.emit()
