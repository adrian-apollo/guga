class_name C_SFX_Player extends ComponentBase

@export var sfx:SFXPack

func _init():
	set(&"resource_local_to_scene", true )

func event_begin():
	sfx.play_random( owner )
