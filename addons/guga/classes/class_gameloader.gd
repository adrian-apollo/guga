extends ColorRect
class_name GameLoader

#	configuration
@export_file() var firstlevel:String
@export var hue:Color
@export var delay:float = 1
@export var mouse_confined:bool = false
@export var mouse_captured:bool = false
@export var loadlevel:bool = true

#	variables
var tree:GugaTree

func _ready() -> void:
	tree = ( Engine.get_main_loop() as GugaTree )
	tree
	entry_config()
	call_deferred("load_first_level")
	
func entry_config():
	#for toggling control and visibility of cursor at game start
	if mouse_confined:
		Input.set_mouse_mode( Input.MOUSE_MODE_CONFINED )
	if mouse_captured:
		Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

	#for changing hue of the background
	color = hue
	#enforces a fullscreen background
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	
	#Delay before loading first level
	await get_tree().create_timer( delay ).timeout

func load_first_level():
	#load first level or not for development purposes
	if loadlevel:
		var newlevel:Level = tree.load_level( firstlevel )
		tree.change_to_level( newlevel, true )
		print( "Startscene >> byebye")
		queue_free()
		return

	print("No start level set")
