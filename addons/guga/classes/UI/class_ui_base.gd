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
	"effects3",
	"debug"
	]

enum LAYERPOSITION{
	TOP,
	BOTTOM,
	MIDDLE
}


	
func _ready():
	for l in layer_names.size():
		var newlayer:CanvasLayer = CanvasLayer.new()
		add_child( newlayer )
		newlayer.name = layer_names[ l ]
		newlayer.layer = l * 10
		newlayer.owner = self

func add_widget_to_layer( widget:UIWidgetBase, layer_name:StringName ) -> bool:
	if !widget:
		return false
	if layer_name.is_empty():
		return false
	if !find_child( layer_name ):
		return false
	
	var layer:CanvasLayer = find_child( layer_name )
	layer.add_child( widget )
	
	widget.owner = find_child( layer_name )
	
	return true

func move_widget_to_layer( widget:UIWidgetBase, layer_name:StringName ):
	if !widget:
		return
	if layer_name.is_empty():
		return
	if !find_child( layer_name ):
		return

	find_child( layer_name ).add_child( widget )
	widget.owner = find_child( layer_name )

func get_layer_with_name( name:StringName ) -> CanvasLayer:
	if name.is_empty():
		return null
		
	return find_child( name )
	
func get_widget_with_name( name:StringName ) -> UIWidgetBase:
	if name.is_empty():
		return null
		
	return find_child( name, true, false )

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

func hide_ui( _visibility:bool = true):
	set("visibility", _visibility)

func focus_on_widget_with_name( _name:StringName ):
	if _name.is_empty():
		return

	for c in get_children():
		if c.name != _name:
			c.visibility = false

func focus_on_widget_by_reference( widget:UIWidgetBase ):
	if !widget:
		return

	for w in get_children():
		if w != widget:
			w.visibility = false

func hide_all_layers( hide:bool = true ):
	for c in get_children():
		c.visibility = hide
