class_name WidgetDebugData extends Control

@export var component_manager:ComponentsManager

func _ready() -> void:
	component_manager.start( self )