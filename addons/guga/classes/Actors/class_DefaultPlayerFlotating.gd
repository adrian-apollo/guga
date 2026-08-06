extends Camera3D
class_name DefaultPlayer_Flotating

@export_category( "Input")
@export var mappingcontext:GUIDEMappingContext
@export var ia_mouse:GUIDEAction
@export var ia_keyboard:GUIDEAction

@export_category( "Motion")
@export var rotate_scale:int = 1
@export var move_scale:int = 1


var movevalue:Vector3
##################################################################
func _ready() -> void:
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	#if componentsmanager:
		#_setupcomponentmanager()
	
func _physics_process(delta: float) -> void:
	movevalue = ia_keyboard.value_axis_3d * delta * move_scale
	translate_object_local( Vector3(movevalue.x, movevalue.z, movevalue.y ) )
	
##################################################################

func _onposses( _controller:PlayerController) -> void:
	if mappingcontext:
		GUIDE.enable_mapping_context(mappingcontext)
		ia_mouse.triggered.connect(mousemove)

func _onunposses( ) -> void:
	GUIDE.disable_mapping_context( mappingcontext )
	
##################################################################
#func _setupcomponentmanager() -> void:
	#if componentsmanager:
		#componentsmanager._initmanager( self )

func mousemove() -> void:
	rotate_y(-deg_to_rad(ia_mouse.value_axis_2d.x) * rotate_scale * get_physics_process_delta_time())
	rotate_object_local(Vector3(-1,0,0), deg_to_rad(ia_mouse.value_axis_2d.y) * rotate_scale * get_physics_process_delta_time())
	
##################################################################
