class_name Level extends Node

@export_group("Configuration")
@export var component_manager:ComponentsManager

func _ready() -> void:
	if component_manager:
		component_manager.start( self )
