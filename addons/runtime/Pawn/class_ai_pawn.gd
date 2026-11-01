class_name CAIPawn
extends CPawn

@export_file("*.gd") var ai_controller_class:String = "uid://dw0ektocywjde"
@export var autopossess:bool = true
@export var auto_destroy_controller:bool = true

var level:Level
var aicontroller:AIController

func event_begin():
	level = tree.current_level
	if autopossess:
		_spawn_ai_controller()

func event_possessed( _controller ) -> bool:
	aicontroller = _controller
	return true

func event_unpossessed( _controller ) -> bool:
	return true

func _spawn_ai_controller():
	if ai_controller_class.is_empty():
		return
	if !ResourceLoader.exists( ai_controller_class):
		return
	
	var newaic:Node = load( ai_controller_class ).new()
	if !newaic.has_method(&"possess"):
		return

	aicontroller = newaic
	aicontroller.componentstack.components.push_back( C_AI_Tree.new() )
	level.add_child( newaic )
	newaic.name = "AIController"
	newaic.owner = level
	aicontroller.possess( owner )

func event_destroy():
	if auto_destroy_controller:
		aicontroller.queue_free()
