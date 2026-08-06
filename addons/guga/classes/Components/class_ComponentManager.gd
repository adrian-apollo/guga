extends Resource
class_name ComponentsManager

#region entry config
@export var components:Array[ComponentBase]
@export var active:bool = true

#endregion

#region properties

var ref_owner:Node

#endregion

#region signals

signal message_component_added
signal message_component_removed
signal message_zero_components

#endregion

#region private

func start( owner:Node) -> void:
	_connecttomailserver()
	ref_owner = owner
	if components.size() > 0 and ref_owner != null:
		_initializecomponents( ref_owner )
	else:
		print( "ComponentManager at " + str( owner ) + " -> " + " zero components")

func _connecttomailserver() -> void:
	MailServer.sendmessage.connect( _mailbox )

func _mailbox(_owner:Node, callable:String, args:Array) -> void:
	if ref_owner == _owner and has_method( callable ):
		if args.size() == 1:
			call(callable, args[0])
			return

		if args.size() > 1:
			call(callable, args)
			return

		if args.is_empty():
			call( callable )
			return

func _initializecomponents( owner:Node ) -> void:
	print( "ComponentManager at " + str( owner ) + " -> initializing " + str( getamountcomponents() ) + " components ")
	for c in components:
		if c:
			configurecomponent( c )

func configurecomponent( component:ComponentBase ) -> void:
	component.owner = ref_owner
	component.componentmanager = self
	component.startcomponent()

#endregion

#region public

func add_component( component: ComponentBase ) -> void:
	components.push_back( component )
	configurecomponent( components[ component ] )
	message_component_added.emit()
	
func delete_component( component: ComponentBase ) -> void:
	components.erase( component )
	message_component_removed.emit()

func getamountcomponents() -> int:
	return components.size()

func findcomponent_bymethodname( method:String) -> ComponentBase:
	for comp in components.size():
		if components.get(comp).has_method(method):
			return components.get(comp)
	return null

func callcomponentmethod(method:String, args:Array) -> void:
	if args.size() == 1:
		findcomponent_bymethodname(method).call(method, args[0])
		return

	if args.size() > 1:
		findcomponent_bymethodname(method).call(method, args)
		return

	if args.is_empty():
		findcomponent_bymethodname(method).call(method)
		return

func findcomponentbysignal( signalname:String) -> ComponentBase:
	for comp in components.size():
		if components.get(comp).has_signal(signalname):
			return components.get(comp)
			break
	return null

func test() -> String:
	print( "Testing component manager" )
	return "Testing component manager"

#endregion
