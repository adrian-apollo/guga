extends ColorRect
class_name MainScene

#	configuration
@export_file() var start_level:String
@export var hue:Color
@export var delay:float = 1
@export var mouse_confined:bool = false
@export var mouse_captured:bool = false
@export var load_level:bool = true

#	variables
var tree:GugaTree

func _ready() -> void:
	tree = ( Engine.get_main_loop() as GugaTree )
	entry_config()
	if start_level.is_empty():
		tree.new_log_message(self, "Empty level reference", tree.LOG_MESSAGE_MODE.NORMAL)
		return

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
	if load_level:
		var newlevel:Level = tree.load_level( start_level )
		tree.change_to_level( newlevel, true )
		queue_free()
