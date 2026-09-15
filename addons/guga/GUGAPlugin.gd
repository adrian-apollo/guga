@tool
extends EditorPlugin

#region

func _enable_plugin() -> void:
	ProjectSettings.set_setting("application/run/main_loop_type", "GugaTree")
	
func _disable_plugin() -> void:
	ProjectSettings.set_setting("application/run/main_loop_type", "SceneTree")
	
#endregion
