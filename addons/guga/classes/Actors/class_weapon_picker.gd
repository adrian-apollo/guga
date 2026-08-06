class_name ItemPicker extends RigidBody3D

@export var component_manager:ComponentsManager
@export var actor_data:ItemData

func _ready() -> void:
	if component_manager:
		component_manager.start( self )
