extends Resource
class_name ComponentsManager

#region entry config
@export var components:Array[ComponentBase]
@export var active:bool = true

#endregion

#region properties

var ref_owner:Node
var conector:Connector = Connector.new()
var tree:GugaTree

#endregion

#region signals

signal message_component_added
signal message_component_removed
signal message_zero_components

#endregion

func _init() -> void:
	tree = ( Engine.get_main_loop() as GugaTree )

#region setup manager

func start( owner:Node) -> void:
	ref_owner = owner
	if components.size() > 0 and ref_owner != null:
		_initialize_components( ref_owner )
	else:
		print( "ComponentManager at " + str( owner ) + " -> " + " zero components")
	
	conector.setup_connector([owner,self])
	
func _initialize_components( owner:Node ) -> void:
	print( "ComponentManager at " + str( owner ) + " -> initializing " + str( getamountcomponents(self) ) + " components ")
	for c in components:
		if c:
			_configurecomponent( c )

func _configurecomponent( component:ComponentBase ) -> void:
	component.owner = ref_owner
	component.componentmanager = self
	component._prebegin()

#endregion

#region components managing

func add_component( component: ComponentBase ) -> void:
	components.push_back( component )
	_configurecomponent( components[ component ] )
	message_component_added.emit()
	
func delete_component( component: ComponentBase ) -> void:
	components.erase( component )
	component.safe_delete()
	message_component_removed.emit()

func getamountcomponents(objref:Object) -> int:
	tree.send_message(objref,"receivedata",[components.size()])
	return components.size()

#endregion

func free():
	for c:ComponentBase in components:
		c.free()
