@tool
extends EditorPlugin
#	Entry point of the Gameplay Tags plugin.
#	Registers the project setting, the "Edit game tags" tool menu entry
#	and the inspector plugin used to pick tags on GamePlayTagsContainer properties.

const Registry := preload("res://addons/gameplay_tags/game_play_tags_registry.gd")
const InspectorPlugin := preload("res://addons/gameplay_tags/editor/tags_inspector_plugin.gd")
const EditorWindow := preload("res://addons/gameplay_tags/editor/tags_editor_window.gd")

const MENU_ITEM_NAME := "Edit game tags"

var _inspector_plugin: EditorInspectorPlugin
var _window: Window


func _enter_tree() -> void:
	_register_project_settings()

	_inspector_plugin = InspectorPlugin.new()
	add_inspector_plugin(_inspector_plugin)

	_window = EditorWindow.new()
	EditorInterface.get_base_control().add_child(_window)

	#	Shows up under Project > Tools.
	add_tool_menu_item(MENU_ITEM_NAME, _on_menu_item_pressed)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM_NAME)
	if _inspector_plugin != null:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	if is_instance_valid(_window):
		_window.queue_free()
		_window = null


func _on_menu_item_pressed() -> void:
	_window.open_editor()


#	Adds the global setting that tells the plugin where the .gts files live.
func _register_project_settings() -> void:
	var path: String = Registry.SETTING_PATH
	if not ProjectSettings.has_setting(path):
		ProjectSettings.set_setting(path, Registry.DEFAULT_DIRECTORY)
	ProjectSettings.set_initial_value(path, Registry.DEFAULT_DIRECTORY)
	ProjectSettings.set_as_basic(path, true)
	ProjectSettings.add_property_info({
		"name": path,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR,
	})
