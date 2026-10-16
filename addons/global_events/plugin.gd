@tool
extends EditorPlugin

const SINGLETON_NAME = "Logging"

const SCRIPT_PATH = "res://addons/logging/logging.gd"

func _enter_tree():
	add_autoload_singleton( SINGLETON_NAME, SCRIPT_PATH)
	print("Logging plugin ready")
	
func _exit_tree():
	remove_autoload_singleton(SINGLETON_NAME )
	print( "Logging plugin removed")
