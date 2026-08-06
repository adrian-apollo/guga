class_name ComponentBase extends Resource

#region import_values
@export_group("Component")
@export var active:bool = true
@export var connect_to_physics_process:bool = true

@export_group("Internal tick")
@export var enabled_custom_tick:bool = false
@export var tick_rate:float = 30

#endregion

#region Properties

var owner:Node
var componentmanager:ComponentsManager
var internal_tick:Timer
var tree:SceneTree
var datareceived
#endregion

#region internal
func _init() -> void:
	tree = Engine.get_main_loop()

func startcomponent() -> void:
	if owner:
		_connecttomailserver()

		if enabled_custom_tick:
			_createtimerbycallable( owner, _tick, 1 / tick_rate )
		else:
			if connect_to_physics_process:
				tree.physics_frame.connect(_tick)
	call_deferred("_begin")

func _connecttomailserver() -> void:
	MailServer.sendmessage.connect( _mailbox )

func _disconnect() -> void:
	disconnect("sendmessage", _mailbox)

func _cleardatareceived() -> void:
	datareceived = null

func _receivedata(data) -> void:
	datareceived = data

#or _owner.name == owner.name or _owner.get_script() == owner.get_script()

func _mailbox(_owner:Node, callable:String, args:Array) -> void:
	if _owner == owner and has_method( callable ):
		if args.size() == 1:
			call(callable, args[0])
			return

		if args.size() > 1:
			call(callable, args)
			return

		if args.is_empty():
			call( callable )
			return
		call_deferred("_cleardatareceived")

func _createtimerbycallable( _owner:Node, callable:Callable, value:float = 1) -> void:

	internal_tick = Timer.new()
	_owner.add_child( internal_tick )
	internal_tick.owner = _owner
	internal_tick.start( value )
	internal_tick.set_autostart( active )
	internal_tick.connect("timeout", callable)

#endregion

#region external
func _begin( ) -> void:
	pass

func _tick() -> void:
	pass

#endregion
