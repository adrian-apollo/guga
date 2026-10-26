@tool
class_name PlayerStart extends Node

##	This is the player scene id on the gamemode.
@export_range(0,7,1,"prefer_slider") var player_number:int = 0:
	set(value):
		player_number = value
		set("name", "PlayerStart_"+ str(player_number))
		if label:
			label.text = name

##	To customize the scale of the sprite and adapt it to every resolution.
@export_range(0,10,0.1, "or_greater") var sprite_scale:float = 1:
	set(value):
		sprite.scale = Vector2( 1, 1 ) * value
		sprite_scale = value

@onready var sprite:Sprite2D = $Control/Sprite2D
@onready var label:Label = $Control/Label

func _enter_tree() -> void:
	player_number = 0
