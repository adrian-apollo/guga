class_name CFPViewportLayer extends ComponentBase

@export_group("Nodes")
@export var subviewport_path:NodePath
@export var fpv_camera_path:NodePath
@export var main_camera_path:NodePath

#region variables
var subviewport:SubViewport
var camera:Camera3D
var maincamera:Camera3D

func _begin( ) -> void:
	if subviewport_path:
		subviewport = AtomMethods.macro_getchildfrompath(owner,subviewport_path)
		#owner.find_child( subviewport_path.get_name( subviewport_path.get_name_count()-1 ) ) 

	if fpv_camera_path:
		camera = AtomMethods.macro_getchildfrompath(owner, fpv_camera_path)

	if main_camera_path:
		maincamera = AtomMethods.macro_getchildfrompath(owner, main_camera_path)

	owner.get_viewport().size_changed.connect( _resizeviewport )
	
	_setenvironment()
	
	_resizeviewport()

func _tick() -> void:
	call_deferred( "_relocatecamera" )

func _resizeviewport() -> void:
	if subviewport:
		subviewport.set_size( owner.get_viewport().get_window().get_size() )

func _relocatecamera() -> void:
	camera.global_transform = maincamera.global_transform

func _setenvironment() -> void:
	maincamera.set_environment( LevelManager.currentlevel.get( "environment" ) )
