@tool
class_name PlayerStart extends Node

@export_range(0,7,1,"prefer_slider") var player_number:int:
	set(value):
		player_number = value
		set("name", "PlayerStart_"+ str(player_number))
		if label:
			label.text = name

@export var label:Label
