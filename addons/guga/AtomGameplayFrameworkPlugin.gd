@tool
extends EditorPlugin

#region

func _enable_plugin() -> void:
	add_autoload_singleton("OnScreenDebugData", "res://addons/AtomGameplayFramework/Singletons/autoload_onscreendebugdata.tscn")
	add_autoload_singleton("LevelManager", "res://addons/AtomGameplayFramework/Singletons/autoload_levelmanager.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("OnScreenDebugData")
	remove_autoload_singleton("LevelManager")

#endregion

#func _ready() -> void:
#	EditorCommandPalette	
