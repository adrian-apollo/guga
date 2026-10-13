class_name UIBase
extends Control

@export var components:ComponentStack

@export var layer_names:PackedStringArray = [
	"world",
	"effects1",
	"indicators",
	"dialogs",
	"gameplay_menus",
	"effects2",
	"game_menus",
	"debug"
	]
	
func _ready():
	for l in layer_names.size():
		var newlayer:CanvasLayer = CanvasLayer.new()
		add_child( newlayer )
		newlayer.name = layer_names[ l ]
		newlayer.layer = l * 10

func add_widget_to_layer( widget:UIWidgetBase, layer:StringName ) -> bool:
	if !widget:
		return false
	if layer.is_empty():
		return false
	
	return true

func remove_widget_from_layer( widget:UIWidgetBase, layer:StringName ) -> bool:
	if !widget:
		return false
	if layer.is_empty():
		return false
	
	return true

func get_layer( name:StringName ) -> CanvasLayer:
	if name.is_empty():
		return null
		
	return find_child( name )
	
func get_widget( name:StringName ) -> UIWidgetBase:
	if name.is_empty():
		return null
		
	return find_child( name, true )

func toggle_widget_visibility_with_name( name:StringName, visible:bool ):
	if name.is_empty():
		return

	var w:UIWidgetBase = find_child( name, true )
	if !w:
		return
	
	w.set("visible", visible)

func toggle_layer_visibility_with_name( name:StringName, visible:bool ):
	if name.is_empty():
		return

	var l:CanvasLayer = find_child( name, true )
	if !l:
		return
	
	l.set("visible", visible)
