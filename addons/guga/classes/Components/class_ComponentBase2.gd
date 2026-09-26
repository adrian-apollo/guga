class_name ComponentBase2 extends Resource

#region configuration
@export_group("Component")
@export var active:bool = true:
	set(value):
		active = value
	get:
		return active
@export_group("Tick")
@export var enabled:bool = true
@export var custom:bool = false
@export_range(1, 60, 1, "or_greater") var tick_rate:int = 1

#endregion

var owner:Node
var componentmanager:ComponentsManager
var tree:GugaTree

func _init():
	tree = Engine.get_main_loop()
	call_deferred("find_local_scene")

func find_local_scene():
	if !is_local_to_scene:
		return
	if !is_instance_valid(get_local_scene()):
		return

	owner = get_local_scene()
	tree.list_component(owner,self)
	setup_tick()

func setup_tick():
	if enabled:
		if custom:
			tree.connect_callable_to_timer(event_tick, tick_rate)
		else:
			tree.physics_frame.connect(event_tick)

	call_deferred("event_begin")

#region virtual methods
func event_begin( ):
	pass

func event_tick():
	pass
	
func event_destroy():
	pass

#endregion

#region the end
#func _notification(what):
	#if !is_instance_valid(self):
		#return
	#if what == NOTIFICATION_PREDELETE:
		#_destructor()

func _destructor():
	event_destroy()
	if tree.physics_frame.is_connected( event_tick ):
		tree.physics_frame.disconnect(event_tick)
		return

	tree.disconnect_callable_from_timer( event_tick, tick_rate )
#endregion
