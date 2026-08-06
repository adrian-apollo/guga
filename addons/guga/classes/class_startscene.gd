extends ColorRect
class_name StartScene

@export var firstlevel:PackedScene
@export var colorhue:Color
@export var delay:float = 1
@export var mouse_confined:bool = false
@export var mouse_captured:bool = false

@export var loadlevel:bool = true

#region

func _ready() -> void:
	print( "Startscene >> ENTRY")
	
	#for toggling control and visibility of cursor at game start
	if mouse_confined:
		Input.set_mouse_mode( Input.MOUSE_MODE_CONFINED )
	if mouse_captured:
		Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

	#for changing hue of the background
	color = colorhue
	#enforces a fullscreen background
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	
	#Delay before loading first level
	await get_tree().create_timer( delay ).timeout
	
	#load first level or not for development purposes
	if loadlevel:
		var newlevel:Level = LevelManager.preloadlevel( firstlevel )
		LevelManager.changetolevel( newlevel, true )
		print( "Startscene >> EXIT")
		queue_free()
	
#endregion
