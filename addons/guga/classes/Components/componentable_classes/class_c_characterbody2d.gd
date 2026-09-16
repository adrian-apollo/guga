class_name CCharacterBody2D extends CharacterBody2D

@export_group("Configuration")
@export var component_manager:ComponentsManager

func _ready() -> void:
	if component_manager:
		component_manager.start( self )
