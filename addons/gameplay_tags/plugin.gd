@tool
extends EditorPlugin
## Entry point of the Gameplay Tags plugin.
## Registers the project setting, the "Edit game tags" tool menu entry
## and the inspector plugin used to pick tags on GamePlayTagsContainer properties.

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

	# Shows up under Project > Tools.
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


## Adds the global settings of the plugin.
func _register_project_settings() -> void:
	_register_setting(
		Registry.SETTING_PATH,
		Registry.DEFAULT_DIRECTORY,
		PROPERTY_HINT_DIR,
		"")
	# Leave this one empty to disable the generation of the GameTags script.
	_register_setting(
		Registry.GENERATED_FILE_SETTING_PATH,
		Registry.DEFAULT_GENERATED_FILE,
		PROPERTY_HINT_SAVE_FILE,
		"*.gd")


func _register_setting(path: String, default_value: String, hint: PropertyHint, hint_string: String) -> void:
	if not ProjectSettings.has_setting(path):
		ProjectSettings.set_setting(path, default_value)
	ProjectSettings.set_initial_value(path, default_value)
	ProjectSettings.set_as_basic(path, true)
	ProjectSettings.add_property_info({
		"name": path,
		"type": TYPE_STRING,
		"hint": hint,
		"hint_string": hint_string,
	})
