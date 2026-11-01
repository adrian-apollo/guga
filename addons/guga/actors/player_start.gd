@tool
class_name PlayerStart extends Node

##	This is the player scene id on the gamemode.
@export_range(0,7,1,"prefer_slider","or_greater") var player_number:int = 0:
	set(value):
		if !Engine.is_editor_hint():
			return
		player_number = value
		set("name", "PlayerStart_"+ str(player_number))
		if label:
			label.text = name

##	To customize the scale of the sprite and adapt it to every resolution.
@export_range(0,10,0.1, "or_greater") var sprite_scale:float = 1:
	set(value):
		if !Engine.is_editor_hint():
			return
		sprite.scale = Vector2( 1, 1 ) * value
		sprite_scale = value

@onready var sprite:Sprite2D = $Control/Sprite2D
@onready var label:Label = $Control/Label

var controller:PlayerController

func _enter_tree():
	if controller and !Engine.is_editor_hint():
		set( &"player_number", controller.player_state.player_id )
		return

	set( &"player_number", 0 )
	
func hide():
	sprite.hide()
	label.hide()
