class_name ComponentBase extends Resource

#region configuration
@export_group("Component")
@export var active:bool = true:
	set(value):
		active = value
	get:
		return active
@export var start_with_tick_enabled:bool = true
@export var custom_tick:bool = false
@export var tick_rate:int = 30

#endregion

#region Properties

var owner:Node
var componentmanager:ComponentsManager
var tree:GugaTree
var conector:Connector = Connector.new()
#endregion

#region initialization
func _init():
	tree = ( Engine.get_main_loop() as GugaTree )

#endregion

#region component initialization
func _prebegin():
	if owner:
		conector.setup_connector([owner,self])
	
	if start_with_tick_enabled:
		if custom_tick:
			tree.connect_callable_to_timer(tick, tick_rate)
		else:
			tree.physics_frame.connect(tick)

	call_deferred("begin")
#endregion

#region virtual methods
func begin( ):
	pass

func tick():
	pass

#endregion

#region the end
func safe_delete():
	#conector.call_deferred( "free" )
	
	if tree.physics_frame.is_connected( tick ):
		tree.physics_frame.disconnect(tick)
		return
	
	tree.disconnect_callable_from_timer( tick, tick_rate )
#endregion
