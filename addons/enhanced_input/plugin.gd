@tool
extends EditorPlugin
## Registers the EnhancedInput autoload when the plugin is enabled.

const AUTOLOAD := "EnhancedInput"
const PATH := "res://addons/enhanced_input/enhanced_input.gd"


func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD, PATH)


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD)
