class_name Level extends Node3D

@export_group("Configuration")
@export var component_manager:ComponentsManager
@export var level_game_mode:LevelGameMode
@export var worldenvironment:WorldEnvironment

var currentcontroller:ComponentBase:
	get:
		return currentcontroller
	set(value):
		currentcontroller = value

var environment:Environment:
	get:
		return environment
	set(value):
		environment = value

func _ready() -> void:
	if component_manager:
		component_manager.start( self )

	set("environmet", worldenvironment.environment )
