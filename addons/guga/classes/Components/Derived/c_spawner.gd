class_name CSpawner2D extends ComponentBase

@export var origin:NodePath
@export var actor_scene:String
@export var spawn_rate:float = 1.0
@export var constant_spawn:bool = false
@export_range( 0, 1000, 1, "hide_control","prefer_slider" ) var amount:int = 0
@export var destroy:bool = false

var spawn_enabled:bool = false
var spawn_node:Node2D
var actor_to_spawn:Resource = null
var origin_node:Node2D
var spawned:int

func event_begin():
	if origin:
		origin_node = tree.get_node_from_nodepath( owner, origin )
	if !actor_scene.is_empty():
		actor_to_spawn = load(actor_scene)

func event_tick():
	if constant_spawn:
		_spawn()
		return

	if spawn_enabled:
		_spawn()

func trigger():
	spawn_enabled = true

func _spawn():
	spawn_enabled = constant_spawn
	if origin.is_empty():
		return
	if amount > 0 and spawned == amount:
		if destroy:
			owner.queue_free()
		return

	if actor_to_spawn:
		var newactor:Node2D = actor_to_spawn.instantiate()
		tree.current_level.add_child( newactor )
		newactor.owner = tree.current_level
		spawned += 1
		if origin:
			newactor.global_position = origin_node.global_position

func _activate_spawner():
	_reset_tick( TICK_SOURCE.CUSTOM, spawn_rate )

func _deactivate_spawner():
	_stop_tick()
	
